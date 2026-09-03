# One node pool per module call. The root module iterates over this module
# with for_each, so every pool is a separate module instance with its own key.
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = var.name
  kubernetes_cluster_id = var.cluster_id
  mode                  = var.mode

  vm_size         = var.vm_size
  os_disk_size_gb = var.os_disk_size_gb

  node_count           = var.node_count
  auto_scaling_enabled = true
  min_count            = var.min_count
  max_count            = var.max_count

  node_labels = var.node_labels
  node_taints = var.node_taints
  tags        = var.tags

  # Node count is owned by the cluster autoscaler at runtime. Without this,
  # every apply resets it and destroys nodes that are running pods.
  lifecycle {
    ignore_changes = [node_count]
  }
}
