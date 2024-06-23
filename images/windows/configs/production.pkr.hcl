// All the values are mandatory

// Nutanix Citrix DaaS Validated Design - Reference prefix for tracking resources
ref_prefix = "WIN_"

// Nutanix Prism Central and Prism Element cluster connection
nutanix_endpoint = "pc70.ntnxlab.local" # Prism Central address (fqdn|IP)
nutanix_cluster  = "PHX-POC070" # Prism Element cluster name
nutanix_subnet   = "Primary_70" # Prism cluster subnet name
nutanix_insecure = "false" # Ignore insecure certificates (true|false)

// Microsoft AD 
ad_domain = "ntnxlab.local"

// ISO images to add into AHV Image Service using Terraform
nutanix_virtio_iso = {
    name = "Nutanix_VirtIO-1.2.3"
    description = "Nutanix VirtIO for Windows (iso) ( Version: 1.2.3 )"
    source_uri = "https://download.nutanix.com/downloads/virtIO/1.2.3/Nutanix-VirtIO-1.2.3.iso"
}

nutanix_server_os_iso = {
    name = "Windows_Server_2022"
    description = "Microsoft Windows Server 2022"
    source_uri = "http://10.42.194.11/users/Matthew%20Ong/en-us_windows_server_2022_uefi_nutanix.iso"
}

// ISO UUIDs after adding with Terraform and to be used by Packer with Autounattend.xml
nutanix_virtio_iso_uuid = "c5267cb4-dcec-44f1-ae9b-837d914f7f2c"
// win10_os_iso_uuid = "<UUID_OUTPUT_FROM_TERRAFORM_ADD_BUILD_ISOS>"
win2022_os_iso_uuid = "7d9b5023-c7af-4621-8d43-5bfcf05299a5"

// AHV disk image built by Packer and to use with Terraform
packer_win2022_disk_image_name = "Windows2022_DataCenter_UEFI_Packer"