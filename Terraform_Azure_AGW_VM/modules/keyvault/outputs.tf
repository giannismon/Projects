output "kv_id" {
  value = azurerm_key_vault.kv.id
}

output "vm_password" {
  value     = azurerm_key_vault_secret.vm_password.value
  sensitive = true
}

output "ssl_certificate_secret_id" {
  value = azurerm_key_vault_certificate.ssl_cert.secret_id
}
