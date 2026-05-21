output "aks_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "key_vault_name" {
  value = module.keyvault.key_vault_name
}

output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "get_password" {
  value = "az keyvault secret show --vault-name ${module.keyvault.key_vault_name} --name postgres-password --query value -o tsv"
}

output "vm_public_ip" {
  value = module.vm.public_ip_address
}

output "vm_ssh" {
  value = "ssh azureuser@${module.vm.public_ip_address}"
}

output "get_vm_password" {
  value = "az keyvault secret show --vault-name ${module.keyvault.key_vault_name} --name vm-admin-password --query value -o tsv"
}
