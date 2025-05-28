variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "Prefix for VM names"
  type        = string
}

variable "template" {
  description = "VM template name to clone from"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size (e.g., '20G')"
  type        = string
  default     = "20G"
}

variable "storage" {
  description = "Storage name for disks"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ip_config" {
  description = "IP configuration (e.g., 'ip=192.168.1.100/24,gw=192.168.1.1' or empty for DHCP)"
  type        = string
  default     = ""
}

variable "user" {
  description = "Default user for cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "password" {
  description = "Default password for cloud-init"
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
  description = "Start VM on boot"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for VM"
  type        = string
  default     = "terraform"
} 