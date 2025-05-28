terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

resource "proxmox_lxc" "lxc" {
  count = var.lxc_count
  
  hostname     = "${var.name_prefix}-${count.index + 1}"
  target_node  = var.proxmox_node
  ostemplate   = var.template
  unprivileged = var.unprivileged
  
  # LXC specs
  cores      = var.cores
  memory     = var.memory
  swap       = var.swap
  
  # Root filesystem
  rootfs {
    storage = var.storage
    size    = var.disk_size
  }
  
  # Network configuration
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = var.ip_config != "" ? var.ip_config : "dhcp"
  }
  
  # LXC configuration
  onboot       = var.onboot
  start        = var.start
  password     = var.password
  ssh_public_keys = var.ssh_keys
  
  tags = var.tags
} 