# VM outputs from module
output "vm_names_module" {
  description = "Names of created VMs (from module)"
  value       = length(module.vms) > 0 ? module.vms[0].vm_names : []
}

output "vm_ids_module" {
  description = "IDs of created VMs (from module)"
  value       = length(module.vms) > 0 ? module.vms[0].vm_ids : []
}

output "vm_ip_addresses_module" {
  description = "IP addresses of created VMs (from module)"
  value       = length(module.vms) > 0 ? module.vms[0].vm_ip_addresses : []
}

# LXC outputs from module
output "lxc_names_module" {
  description = "Names of created LXC containers (from module)"
  value       = length(module.lxcs) > 0 ? module.lxcs[0].lxc_names : []
}

output "lxc_ids_module" {
  description = "IDs of created LXC containers (from module)"
  value       = length(module.lxcs) > 0 ? module.lxcs[0].lxc_ids : []
}

output "lxc_ip_addresses_module" {
  description = "IP addresses of created LXC containers (from module)"
  value       = length(module.lxcs) > 0 ? module.lxcs[0].lxc_ip_addresses : []
}

# Summary from modules
output "infrastructure_summary_module" {
  description = "Summary of created infrastructure (from modules)"
  value = {
    vm_count  = length(module.vms) > 0 ? length(module.vms[0].vm_names) : 0
    lxc_count = length(module.lxcs) > 0 ? length(module.lxcs[0].lxc_names) : 0
    total     = (length(module.vms) > 0 ? length(module.vms[0].vm_names) : 0) + (length(module.lxcs) > 0 ? length(module.lxcs[0].lxc_names) : 0)
    node      = var.proxmox_node
  }
} 