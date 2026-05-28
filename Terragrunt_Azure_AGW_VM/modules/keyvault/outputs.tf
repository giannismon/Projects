output "kv_id" {
  value = azurerm_key_vault.kv.id
}

output "ssl_certificate_secret_id" {
  value = azurerm_key_vault_certificate.ssl_cert.secret_id
}
