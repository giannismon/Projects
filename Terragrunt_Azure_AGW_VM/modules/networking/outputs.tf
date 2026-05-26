output "vm_subnet_id" {
  value = azurerm_subnet.vm_subnet.id
}

output "agw_subnet_id" {
  value = azurerm_subnet.agw_subnet.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion_subnet.id
}
