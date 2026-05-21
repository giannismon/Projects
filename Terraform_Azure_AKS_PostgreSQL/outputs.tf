output "key_vault_name" {
  value = module.keyvault.key_vault_name
}

output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}

output "verify_secret" {
  value = "kubectl logs deployment/app"
}
