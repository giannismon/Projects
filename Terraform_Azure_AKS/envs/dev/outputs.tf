output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "get_credentials_command" {
  description = "Ready to copy-paste once the cluster is up"
  value       = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name} --overwrite-existing"
}
