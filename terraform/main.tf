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
  # pm_api_token_id     = var.proxmox_api_token_id
  # pm_api_token_secret = var.proxmox_api_token_secret
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
} 