output "disk_ids" {
  description = "Map logical name => managed disk id."
  value       = { for k, d in azurerm_managed_disk.disk : k => d.id }
}

output "disk_names" {
  description = "Map logical name => managed disk name."
  value       = { for k, d in azurerm_managed_disk.disk : k => d.name }
}
