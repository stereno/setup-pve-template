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

# VM Module
module "vms" {
  source = "./modules/proxmox-vm"
  
  # Only create VMs if vm_count > 0 and template is provided
  count = var.vm_count > 0 && var.vm_template != "" ? 1 : 0
  
  proxmox_node    = var.proxmox_node
  vm_count        = var.vm_count
  name_prefix     = var.vm_name_prefix
  template        = var.vm_template
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  memory          = var.vm_memory
  disk_size       = var.vm_disk_size
  storage         = var.vm_storage
  network_bridge  = var.vm_network_bridge
  ip_config       = var.vm_ip_config
  user            = var.vm_user
  password        = var.vm_password
  ssh_keys        = var.vm_ssh_keys
  onboot          = var.vm_onboot
  tags            = var.vm_tags
}

# LXC Module
module "lxcs" {
  source = "./modules/proxmox-lxc"
  
  # Only create LXCs if lxc_count > 0 and template is provided
  count = var.lxc_count > 0 && var.lxc_template != "" ? 1 : 0
  
  proxmox_node    = var.proxmox_node
  lxc_count       = var.lxc_count
  name_prefix     = var.lxc_name_prefix
  template        = var.lxc_template
  unprivileged    = var.lxc_unprivileged
  cores           = var.lxc_cores
  memory          = var.lxc_memory
  swap            = var.lxc_swap
  disk_size       = var.lxc_disk_size
  storage         = var.lxc_storage
  network_bridge  = var.lxc_network_bridge
  ip_config       = var.lxc_ip_config
  password        = var.lxc_password
  ssh_keys        = var.lxc_ssh_keys
  onboot          = var.lxc_onboot
  start           = var.lxc_start
  tags            = var.lxc_tags
} 