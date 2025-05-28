output "lxc_names" {
  description = "Names of created LXC containers"
  value       = proxmox_lxc.lxc[*].hostname
}

output "lxc_ids" {
  description = "IDs of created LXC containers"
  value       = proxmox_lxc.lxc[*].vmid
}

output "lxc_ip_addresses" {
  description = "IP addresses of created LXC containers"
  value       = [for lxc in proxmox_lxc.lxc : lxc.network[0].ip]
}

output "lxc_instances" {
  description = "Full LXC instance objects"
  value       = proxmox_lxc.lxc
} 