output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "node_resource_group" {
  description = "The MC_* resource group where the node VMs live — check costs here"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity_object_id" {
  description = "Needed when granting the cluster access to ACR or Key Vault"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "node_pools" {
  description = "User pools created by the module, with their effective labels"
  value       = { for k, m in module.node_pool : k => m.node_labels }
}

output "get_credentials_command" {
  description = "Ready to copy-paste once the cluster is up"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing"
}

output "kube_config_raw" {
  description = "Full kubeconfig — contains credentials"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
