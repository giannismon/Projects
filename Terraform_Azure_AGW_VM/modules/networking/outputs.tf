output "subnet_ids" {
  description = "Map logical name => subnet id."
  value       = { for k, s in azurerm_subnet.subnet : k => s.id }
}

output "subnet_names" {
  description = "Map logical name => Azure subnet name."
  value       = { for k, s in azurerm_subnet.subnet : k => s.name }
}

output "vnet_id" {
  description = "Id of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}
