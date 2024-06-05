source "nutanix" "ubuntu-server" {

  // Prism Central Endpoint Settings and Credentials
  nutanix_username = var.nutanix_username
  nutanix_password = var.nutanix_password
  nutanix_endpoint = var.nutanix_endpoint
  nutanix_port     = var.nutanix_port
  nutanix_insecure = var.nutanix_insecure

  // Prism Element Cluster
  cluster_name = var.nutanix_cluster

  // Virtual Machine Settings
  cpu       = var.nutanix_vm_cpu
  os_type   = local.os_family
  memory_mb = var.nutanix_vm_memory_mb
  boot_type = var.nutanix_vm_boot_type

  vm_nics {
    # subnet_name = var.nutanix_subnet # Cannot be used if there are more than one subnet with the same name. It happens when PC manages multiple PE clusters
    subnet_uuid = var.nutanix_subnet
  }

  // Virtual Machine Connection
  ssh_password     = var.build_password
  ssh_username     = var.build_username

  // AHV Disk Image Creation
  force_deregister  = true

  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "2m"
}