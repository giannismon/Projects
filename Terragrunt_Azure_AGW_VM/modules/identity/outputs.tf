output "identity_id" {
  value = azurerm_user_assigned_identity.agw_identity.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.agw_identity.principal_id
}
