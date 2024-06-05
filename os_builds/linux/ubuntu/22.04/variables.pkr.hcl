// Tradeshow Prefix

variable "ref_prefix" {
  type        = string
  description = "Prefix to include at the start of a resource name"
  default     = "DND-"
}

// Prism Central credentials

variable "nutanix_username" {
  type        = string
  description = "This is the username for the Prism Central instance. Required for provider"
}

variable "nutanix_password" {
  type        = string
  description = "This is the password for the Prism Central instance. Required for provider"
  sensitive   = true
}

variable "nutanix_endpoint" {
  type        = string
  description = "This is the IP address or FQDN for the Prism Central instance. Required for provider"
}

variable "nutanix_port" {
  type        = number
  description = "This is the port for the Prism Central instance. Required for provider"
  default     = 9440
}

variable "nutanix_insecure" {
  type        = bool
  description = "This specifies whether to allow verify ssl certificates. Required for provider"
  default     = false
}

variable "nutanix_wait" {
  type        = number
  description = "This specifies the timeout on all resource operations in the provider in minutes. Required for provider"
  default     = 1
}

// Prism settings

variable "nutanix_cluster" {
  type        = string
  description = "This is the Prism Element cluster name. Required for building the image"
  default = "PRIMARY"
}

variable "nutanix_subnet" {
  type        = string
  description = "This is the Prism Element subnet name or UUID. Use UUID if there are multiple subnets with the same name. Required for building the image"
  default = "04af09bc-0de9-4114-9eb7-8d2adcfc3595"
}

// Virtual machine settings

variable "nutanix_vm_cpu" {
  type        = number
  description = "Number of virtual CPUs. Required for building the image"
  default     = 4
}

variable "nutanix_vm_memory_mb" {
  type        = number
  description = "Virtual machine memory. Required for building the image"
  default     = 8192
}

variable "nutanix_vm_boot_type" {
  type        = string
  description = "Virtual machine boot type. Required for building the image"
  default     = "legacy" # Options: legacy / uefi
}

variable "nutanix_vm_disk_size_gb" {
  type        = number
  description = "Virtual machine disk size (GB). Required for building the image"
  default     = 100
}

# variable "os_image" {
#   type        = string
#   description = "Operating system ISO name, UUID, URL for downloading. Use UUID if there are multiple images with the same name. Required for building the image"
# }

// Packer connection settings

variable "build_username" {
  type        = string
  description = "Packer username. Required by Packer for connecting to the guest OS"
  default = "ubuntu"
}

variable "build_password" {
  type        = string
  description = "Packer password. Required by Packer for connecting to the guest OS"
  sensitive   = true
  default = "nutanix/4u"
}
