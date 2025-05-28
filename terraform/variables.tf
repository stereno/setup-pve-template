# Proxmox connection variables
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., root@pam) - パスワード認証の場合"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password - パスワード認証の場合（APIトークン使用時は空のまま）"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification - 自己署名証明書の場合はtrue"
  type        = bool
  default     = true
}

# API Token authentication (recommended over password)
variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (e.g., user@pam!token-name) - APIトークン認証の場合"
  type        = string
  default     = ""
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret - APIトークン認証の場合"
  type        = string
  default     = ""
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name (e.g., pve)"
  type        = string
}

# VM configuration variables
variable "vm_count" {
  description = "Number of VMs to create (0 = VMを作成しない)"
  type        = number
  default     = 0
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm"
}

variable "vm_template" {
  description = "VM template name to clone from (VM作成時に必要)"
  type        = string
  default     = ""
}

variable "vm_cores" {
  description = "Number of CPU cores for VMs"
  type        = number
  default     = 2
}

variable "vm_sockets" {
  description = "Number of CPU sockets for VMs"
  type        = number
  default     = 1
}

variable "vm_memory" {
  description = "Memory size in MB for VMs"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk size for VMs (e.g., '20G')"
  type        = string
  default     = "20G"
}

variable "vm_storage" {
  description = "Storage name for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "vm_ip_config" {
  description = "IP configuration for VMs (e.g., 'ip=192.168.1.100/24,gw=192.168.1.1' or leave empty for DHCP)"
  type        = string
  default     = ""
}

variable "vm_user" {
  description = "Default user for VM cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "Default password for VM cloud-init"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vm_ssh_keys" {
  description = "SSH public keys for VMs"
  type        = string
  default     = ""
}

variable "vm_onboot" {
  description = "Start VMs on boot"
  type        = bool
  default     = false
}

variable "vm_tags" {
  description = "Tags for VMs"
  type        = string
  default     = "terraform"
}

# LXC configuration variables
variable "lxc_count" {
  description = "Number of LXC containers to create (0 = LXCを作成しない)"
  type        = number
  default     = 0
}

variable "lxc_name_prefix" {
  description = "Prefix for LXC container names"
  type        = string
  default     = "lxc"
}

variable "lxc_template" {
  description = "LXC template name (LXC作成時に必要, e.g., 'local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst')"
  type        = string
  default     = ""
}

variable "lxc_unprivileged" {
  description = "Create unprivileged LXC containers"
  type        = bool
  default     = true
}

variable "lxc_cores" {
  description = "Number of CPU cores for LXC containers"
  type        = number
  default     = 1
}

variable "lxc_memory" {
  description = "Memory size in MB for LXC containers"
  type        = number
  default     = 512
}

variable "lxc_swap" {
  description = "Swap size in MB for LXC containers"
  type        = number
  default     = 512
}

variable "lxc_disk_size" {
  description = "Disk size for LXC containers (e.g., '8G')"
  type        = string
  default     = "8G"
}

variable "lxc_storage" {
  description = "Storage name for LXC containers"
  type        = string
  default     = "local-lvm"
}

variable "lxc_network_bridge" {
  description = "Network bridge for LXC containers"
  type        = string
  default     = "vmbr0"
}

variable "lxc_ip_config" {
  description = "IP configuration for LXC containers (e.g., '192.168.1.101/24' or leave empty for DHCP)"
  type        = string
  default     = ""
}

variable "lxc_password" {
  description = "Root password for LXC containers"
  type        = string
  sensitive   = true
  default     = ""
}

variable "lxc_ssh_keys" {
  description = "SSH public keys for LXC containers"
  type        = string
  default     = ""
}

variable "lxc_onboot" {
  description = "Start LXC containers on boot"
  type        = bool
  default     = false
}

variable "lxc_start" {
  description = "Start LXC containers after creation"
  type        = bool
  default     = true
}

variable "lxc_tags" {
  description = "Tags for LXC containers"
  type        = string
  default     = "terraform"
}

# === Tailscale Configuration ===

variable "tailscale_enabled" {
  description = "Enable Tailscale setup on VMs and LXCs"
  type        = bool
  default     = false
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key (create at https://login.tailscale.com/admin/settings/keys)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tailscale_hostname_prefix" {
  description = "Hostname prefix for Tailscale nodes (will be suffixed with VM/LXC number)"
  type        = string
  default     = "proxmox"
}

variable "tailscale_ssh_enabled" {
  description = "Enable Tailscale SSH (allows SSH access via Tailscale network)"
  type        = bool
  default     = true
}

variable "tailscale_exit_node" {
  description = "Configure as Tailscale exit node (advertise routes)"
  type        = bool
  default     = false
}

variable "tailscale_tags" {
  description = "Tailscale ACL tags (comma-separated, e.g., 'tag:server,tag:dev')"
  type        = string
  default     = ""
}

variable "tailscale_subnet_routes" {
  description = "Subnet routes to advertise (for exit node, e.g., '192.168.1.0/24')"
  type        = string
  default     = ""
} 