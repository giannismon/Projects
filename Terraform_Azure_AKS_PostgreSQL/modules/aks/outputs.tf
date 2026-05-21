output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0]
  sensitive = true
}
