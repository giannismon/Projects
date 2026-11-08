output "vm_ids" {
  description = "Map logical name => VM resource id."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_names" {
  description = "Map logical name => Azure VM name."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.name }
}

output "private_ips" {
  description = "Map logical name => private IP του NIC."
  value       = { for k, n in azurerm_network_interface.nic : k => n.private_ip_address }
}
