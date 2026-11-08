output "kv_id" {
  description = "Id του Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "secret_values" {
  description = "Map secret name => τιμή."
  value       = { for k, s in azurerm_key_vault_secret.secret : k => s.value }
  sensitive   = true
}

output "secret_ids" {
  description = "Map secret name => versionless secret id."
  value       = { for k, s in azurerm_key_vault_secret.secret : k => s.versionless_id }
}

output "certificate_secret_ids" {
  description = "Map certificate name => secret id (αυτό θέλει το Application Gateway)."
  value       = { for k, c in azurerm_key_vault_certificate.cert : k => c.secret_id }
}
