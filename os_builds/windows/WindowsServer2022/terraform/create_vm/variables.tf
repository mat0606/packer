// Nutanix Validated Design Prefix

variable "ref_prefix" {
  type        = string
  description = "Prefix to include at the start of a resource name"
  default     = "NTNX_"
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
  description = "This is the Prism Element cluster name. Required by Terraform"
}

variable "nutanix_subnet" {
  type        = string
  description = "This is the Prism Element subnet name. Required by Terraform"
}

// Microsoft Active Directory domain settings and credentials

variable "ad_domain" {
  type        = string
  description = "This is the domain for joining the virtual machine. Required by Citrix Cloud Connector"
}

variable "ad_username" {
  type        = string
  description = "This is the username for joining the virtual machine into the domain. Required by Citrix Cloud Connector"
}

variable "ad_password" {
  type        = string
  description = "This is the password for joining the virtual machine into the domain. Required by Citrix Cloud Connector"
  sensitive   = true
}

// Citrix Cloud Connector VM settings

variable "windows_server_sysprep_vm_name" {
  type        = list(string)
  description = <<-EOT
    This is the list of VM names
  EOT
}

variable "windows_server_vm_config" {
  type = object({
    num_sockets          = number
    memory_size_mib      = number
    num_vcpus_per_socket = number
    disk_size_mib        = number
  })
  default = {
    num_sockets          = 2
    memory_size_mib      = 8    # Value on GB
    disk_size_mib        = 60   # Value on GB
    num_vcpus_per_socket = 1
  }
  description = "This is the virtual machine hardware settings. Required by Terraform" // https://docs.citrix.com/en-us/citrix-cloud/citrix-cloud-resource-locations/citrix-cloud-connector/technical-details.html#system-requirements
}

variable "packer_win2022_disk_image_name" {
  type        = string
  description = "This is the disk image name built by Packer. Required by Terraform"
}

// Guest OS settings

variable "os_user_language" {
  type        = string
  description = "Windows user language. Required by Sysprep for building the image"
  default     = "en-US"
}

variable "os_user_keyboard" {
  type        = string
  description = "Windows user keyboard. Required by Sysprep for building the image"
  default     = "en-US"
}

variable "os_user_timezone" {
  type        = string
  description = "Windows user timezone. Required by Sysprep for building the image"
  default     = "UTC"
}

variable "os_organization" {
  type        = string
  description = "This is the organization name. Required by Sysprep for building the image"
  default     = "Organization"
}

variable "os_owner" {
  type        = string
  description = "This is the machine owner's name. Required by Sysprep for building the image"
  default     = "Owner"
}
