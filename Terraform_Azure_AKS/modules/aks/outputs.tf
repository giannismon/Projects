output "resource_group_name" {
  description = "The resource group holding the cluster"
  value       = azurerm_resource_group.this.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "node_resource_group" {
  description = "The MC_* resource group where the node VMs live — check costs here"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity_object_id" {
  description = "Needed when granting the cluster access to ACR or Key Vault"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "kube_config_raw" {
  description = "Full kubeconfig — contains credentials"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
