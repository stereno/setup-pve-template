terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count
  
  name         = "${var.name_prefix}-${count.index + 1}"
  target_node  = var.proxmox_node
  clone        = var.template
  full_clone   = true
  
  # VM specs
  cores    = var.cores
  sockets  = var.sockets
  memory   = var.memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  
  disk {
    slot         = 0
    size         = var.disk_size
    type         = "scsi"
    storage      = var.storage
    iothread     = 1
  }
  
  network {
    model  = "virtio"
    bridge = var.network_bridge
  }
  
  # Cloud-init configuration
  os_type      = "cloud-init"
  ipconfig0    = var.ip_config != "" ? var.ip_config : "dhcp"
  ciuser       = var.user
  cipassword   = var.password
  sshkeys      = var.ssh_keys
  
  # VM lifecycle
  onboot       = var.onboot
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
  
  tags = var.tags
} 