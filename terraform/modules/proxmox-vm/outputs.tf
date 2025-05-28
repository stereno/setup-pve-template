output "vm_names" {
  description = "Names of created VMs"
  value       = proxmox_vm_qemu.vm[*].name
}

output "vm_ids" {
  description = "IDs of created VMs"
  value       = proxmox_vm_qemu.vm[*].vmid
}

output "vm_ip_addresses" {
  description = "IP addresses of created VMs"
  value       = proxmox_vm_qemu.vm[*].default_ipv4_address
}

output "vm_instances" {
  description = "Full VM instance objects"
  value       = proxmox_vm_qemu.vm
} 