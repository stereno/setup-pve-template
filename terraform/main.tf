terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

# Proxmox Provider configuration
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = var.proxmox_tls_insecure
  
  # API Token authentication (recommended)
  # Uncomment these lines and comment password auth above to use API tokens
  # pm_api_token_id     = var.proxmox_api_token_id
  # pm_api_token_secret = var.proxmox_api_token_secret
}

# Tailscale setup script (conditional)
locals {
  tailscale_script = var.tailscale_enabled ? templatefile("${path.module}/cloud-init/tailscale-setup.sh", {}) : ""
  
  # VM用のcloud-init設定
  vm_cloud_init_parts = var.tailscale_enabled ? [
    {
      content_type = "text/x-shellscript"
      content = templatefile("${path.module}/cloud-init/tailscale-setup.sh", {})
      filename = "tailscale-setup.sh"
    }
  ] : []
  
  # Tailscale環境変数
  tailscale_env_vars = var.tailscale_enabled ? {
    TAILSCALE_AUTH_KEY = var.tailscale_auth_key
    TAILSCALE_SSH_ENABLED = var.tailscale_ssh_enabled ? "true" : "false"
    TAILSCALE_EXIT_NODE = var.tailscale_exit_node ? "true" : "false"
    TAILSCALE_TAGS = var.tailscale_tags
    TAILSCALE_SUBNET_ROUTES = var.tailscale_subnet_routes
  } : {}
}

# VM instances
resource "proxmox_vm_qemu" "vm_instances" {
  count = var.vm_count
  
  name         = "${var.vm_name_prefix}-${count.index + 1}"
  target_node  = var.proxmox_node
  clone        = var.vm_template
  full_clone   = true
  
  # VM specs
  cores    = var.vm_cores
  sockets  = var.vm_sockets
  memory   = var.vm_memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  
  disk {
    slot         = 0
    size         = var.vm_disk_size
    type         = "scsi"
    storage      = var.vm_storage
    iothread     = 1
  }
  
  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }
  
  # Cloud-init configuration
  os_type      = "cloud-init"
  ipconfig0    = var.vm_ip_config != "" ? var.vm_ip_config : "dhcp"
  ciuser       = var.vm_user
  cipassword   = var.vm_password
  sshkeys      = var.vm_ssh_keys
  
  # Tailscale cloud-init setup (if enabled)
  cicustom = var.tailscale_enabled ? "user=local:snippets/vm-${count.index + 1}-user.yml" : null
  
  # VM lifecycle
  onboot       = var.vm_onboot
  agent        = 1
  
  lifecycle {
    ignore_changes = [
      network,
      desc,
      numa,
      tablet,
      memory,
    ]
  }
  
  tags = var.vm_tags
}

# VM用のTailscale cloud-init設定ファイル
resource "local_file" "vm_tailscale_cloud_init" {
  count = var.tailscale_enabled ? var.vm_count : 0
  
  filename = "${path.module}/generated/vm-${count.index + 1}-user.yml"
  content = templatefile("${path.module}/cloud-init/vm-cloud-init.yml.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    tailscale_hostname = "${var.tailscale_hostname_prefix}-vm-${count.index + 1}"
    tailscale_ssh_enabled = var.tailscale_ssh_enabled
    tailscale_exit_node = var.tailscale_exit_node
    tailscale_tags = var.tailscale_tags
    tailscale_subnet_routes = var.tailscale_subnet_routes
  })
  
  provisioner "local-exec" {
    command = "echo 'Generated cloud-init config for VM ${count.index + 1}'"
  }
}

# LXC containers
resource "proxmox_lxc" "lxc_instances" {
  count = var.lxc_count
  
  hostname     = "${var.lxc_name_prefix}-${count.index + 1}"
  target_node  = var.proxmox_node
  ostemplate   = var.lxc_template
  unprivileged = var.lxc_unprivileged
  
  # LXC specs
  cores      = var.lxc_cores
  memory     = var.lxc_memory
  swap       = var.lxc_swap
  
  # Root filesystem
  rootfs {
    storage = var.lxc_storage
    size    = var.lxc_disk_size
  }
  
  # Network configuration
  network {
    name   = "eth0"
    bridge = var.lxc_network_bridge
    ip     = var.lxc_ip_config != "" ? var.lxc_ip_config : "dhcp"
  }
  
  # LXC configuration
  onboot       = var.lxc_onboot
  start        = var.lxc_start
  password     = var.lxc_password
  ssh_public_keys = var.lxc_ssh_keys
  
  tags = var.lxc_tags
  
  # Tailscale setup for LXC (post-creation)
  provisioner "local-exec" {
    command = var.tailscale_enabled ? "echo 'LXC ${self.hostname} created, Tailscale setup needed'" : "echo 'LXC ${self.hostname} created'"
  }
}

# LXC Tailscale setup script execution
resource "null_resource" "lxc_tailscale_setup" {
  count = var.tailscale_enabled ? var.lxc_count : 0
  
  depends_on = [proxmox_lxc.lxc_instances]
  
  provisioner "local-exec" {
    command = <<-EOT
      # Wait for LXC to be ready
      sleep 30
      
      # Copy and execute Tailscale setup script
      pct exec ${proxmox_lxc.lxc_instances[count.index].vmid} -- bash -c "
        export TAILSCALE_AUTH_KEY='${var.tailscale_auth_key}'
        export TAILSCALE_HOSTNAME='${var.tailscale_hostname_prefix}-lxc-${count.index + 1}'
        export TAILSCALE_SSH_ENABLED='${var.tailscale_ssh_enabled}'
        export TAILSCALE_EXIT_NODE='${var.tailscale_exit_node}'
        export TAILSCALE_TAGS='${var.tailscale_tags}'
        export TAILSCALE_SUBNET_ROUTES='${var.tailscale_subnet_routes}'
        
        curl -fsSL https://tailscale.com/install.sh | sh
        systemctl enable tailscaled
        systemctl start tailscaled
        
        TAILSCALE_CMD=\"tailscale up --auth-key=\$TAILSCALE_AUTH_KEY --hostname=\$TAILSCALE_HOSTNAME\"
        
        if [ \"\$TAILSCALE_SSH_ENABLED\" = \"true\" ]; then
          TAILSCALE_CMD=\"\$TAILSCALE_CMD --ssh\"
        fi
        
        if [ \"\$TAILSCALE_EXIT_NODE\" = \"true\" ]; then
          TAILSCALE_CMD=\"\$TAILSCALE_CMD --advertise-exit-node\"
        fi
        
        if [ -n \"\$TAILSCALE_TAGS\" ]; then
          TAILSCALE_CMD=\"\$TAILSCALE_CMD --advertise-tags=\$TAILSCALE_TAGS\"
        fi
        
        if [ -n \"\$TAILSCALE_SUBNET_ROUTES\" ]; then
          TAILSCALE_CMD=\"\$TAILSCALE_CMD --advertise-routes=\$TAILSCALE_SUBNET_ROUTES\"
        fi
        
        TAILSCALE_CMD=\"\$TAILSCALE_CMD --accept-routes --accept-dns\"
        
        eval \"\$TAILSCALE_CMD\"
        
        sleep 10
        tailscale status
        
        echo 'Tailscale setup completed for LXC ${count.index + 1}'
      "
    EOT
  }
  
  triggers = {
    lxc_id = proxmox_lxc.lxc_instances[count.index].vmid
  }
} 