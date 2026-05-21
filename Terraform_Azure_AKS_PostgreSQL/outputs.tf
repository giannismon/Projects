output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "check_logs" {
  value = "kubectl logs job/test-secret"
}
