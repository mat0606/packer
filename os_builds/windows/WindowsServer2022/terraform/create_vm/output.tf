output "connector_vm_ips" {
  value = nutanix_virtual_machine.windows_server.*.nic_list_status.0.ip_endpoint_list.0.ip
}