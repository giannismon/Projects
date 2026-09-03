# One node pool per module call. The root module iterates over this module
# with for_each, so every pool is a separate module instance with its own key.
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = var.name
  kubernetes_cluster_id = var.cluster_id
  mode                  = var.pool.mode

  vm_size         = var.pool.vm_size
  os_disk_size_gb = var.pool.os_disk_size_gb

  node_count           = var.pool.node_count
  auto_scaling_enabled = true
  min_count            = var.pool.min_count
  max_count            = var.pool.max_count

  # Shared labels plus pool-specific ones. On conflict the pool wins.
  node_labels = merge(var.common_labels, var.pool.node_labels)
  node_taints = var.pool.node_taints
  tags        = var.tags

  # Node count is owned by the cluster autoscaler at runtime. Without this,
  # every apply resets it and destroys nodes that are running pods.
  lifecycle {
    ignore_changes = [node_count]
  }
}
