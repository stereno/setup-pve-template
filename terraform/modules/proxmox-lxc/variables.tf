variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "lxc_count" {
  description = "Number of LXC containers to create"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "Prefix for LXC container names"
  type        = string
}

variable "template" {
  description = "LXC template name"
  type        = string
}

variable "unprivileged" {
  description = "Create unprivileged LXC containers"
  type        = bool
  default     = true
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
  default     = 512
}

variable "swap" {
  description = "Swap size in MB"
  type        = number
  default     = 512
}

variable "disk_size" {
  description = "Disk size (e.g., '8G')"
  type        = string
  default     = "8G"
}

variable "storage" {
  description = "Storage name for containers"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ip_config" {
  description = "IP configuration (e.g., '192.168.1.101/24' or empty for DHCP)"
  type        = string
  default     = ""
}

variable "password" {
  description = "Root password for containers"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_keys" {
  description = "SSH public keys"
  type        = string
  default     = ""
}

variable "onboot" {
  description = "Start containers on boot"
  type        = bool
  default     = false
}

variable "start" {
  description = "Start containers after creation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for containers"
  type        = string
  default     = "terraform"
} 