output "id" {
  value = azurerm_kubernetes_cluster_node_pool.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster_node_pool.this.name
}

output "node_labels" {
  description = "Labels that ended up on the nodes — use these in nodeSelector"
  value       = azurerm_kubernetes_cluster_node_pool.this.node_labels
}
