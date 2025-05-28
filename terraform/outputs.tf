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
  value = [
    for lxc in proxmox_lxc.lxc_instances : 
    try(lxc.network[0].ip, "DHCP")
  ]
}

# === Tailscale Outputs ===

output "tailscale_enabled" {
  description = "Whether Tailscale is enabled"
  value       = var.tailscale_enabled
}

output "tailscale_vm_hostnames" {
  description = "Tailscale hostnames for VMs"
  value = var.tailscale_enabled ? [
    for i in range(var.vm_count) : "${var.tailscale_hostname_prefix}-vm-${i + 1}"
  ] : []
}

output "tailscale_lxc_hostnames" {
  description = "Tailscale hostnames for LXC containers"
  value = var.tailscale_enabled ? [
    for i in range(var.lxc_count) : "${var.tailscale_hostname_prefix}-lxc-${i + 1}"
  ] : []
}

output "tailscale_ssh_commands" {
  description = "SSH commands to connect via Tailscale"
  value = var.tailscale_enabled && var.tailscale_ssh_enabled ? {
    vms = [
      for i in range(var.vm_count) : "ssh ${var.tailscale_hostname_prefix}-vm-${i + 1}"
    ]
    lxcs = [
      for i in range(var.lxc_count) : "ssh root@${var.tailscale_hostname_prefix}-lxc-${i + 1}"
    ]
  } : {}
}

output "setup_instructions" {
  description = "Instructions for accessing the infrastructure"
  value = var.tailscale_enabled ? {
    message = "🎉 Infrastructure with Tailscale SSH ready!"
    vm_access = var.vm_count > 0 ? [
      for i in range(var.vm_count) : {
        name = "${var.vm_name_prefix}-${i + 1}"
        tailscale_hostname = "${var.tailscale_hostname_prefix}-vm-${i + 1}"
        ssh_command = "ssh ${var.tailscale_hostname_prefix}-vm-${i + 1}"
        user = var.vm_user
      }
    ] : []
    lxc_access = var.lxc_count > 0 ? [
      for i in range(var.lxc_count) : {
        name = "${var.lxc_name_prefix}-${i + 1}"
        tailscale_hostname = "${var.tailscale_hostname_prefix}-lxc-${i + 1}"
        ssh_command = "ssh root@${var.tailscale_hostname_prefix}-lxc-${i + 1}"
        user = "root"
      }
    ] : []
    notes = [
      "✅ Tailscale SSH is enabled",
      "🔗 Connect from any device on your Tailscale network",
      "📱 Install Tailscale on your client: https://tailscale.com/download",
      "🔍 Check node status: tailscale status"
    ]
  } : {
    message = "Infrastructure ready without Tailscale"
    notes = ["Set tailscale_enabled = true to enable Tailscale SSH access"]
  }
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