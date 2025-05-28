# VM outputs
output "vm_names" {
  description = "Names of created VMs"
  value       = proxmox_vm_qemu.vm_instances[*].name
}

output "vm_ids" {
  description = "IDs of created VMs"
  value       = proxmox_vm_qemu.vm_instances[*].vmid
}

output "vm_ip_addresses" {
  description = "IP addresses of created VMs"
  value       = proxmox_vm_qemu.vm_instances[*].default_ipv4_address
}

# LXC outputs
output "lxc_names" {
  description = "Names of created LXC containers"
  value       = proxmox_lxc.lxc_instances[*].hostname
}

output "lxc_ids" {
  description = "IDs of created LXC containers"
  value       = proxmox_lxc.lxc_instances[*].vmid
}

output "lxc_ip_addresses" {
  description = "IP addresses of created LXC containers"
  value       = [for lxc in proxmox_lxc.lxc_instances : lxc.network[0].ip]
}

# Summary
output "infrastructure_summary" {
  description = "Summary of created infrastructure"
  value = {
    vm_count  = length(proxmox_vm_qemu.vm_instances)
    lxc_count = length(proxmox_lxc.lxc_instances)
    total     = length(proxmox_vm_qemu.vm_instances) + length(proxmox_lxc.lxc_instances)
    node      = var.proxmox_node
  }
} 