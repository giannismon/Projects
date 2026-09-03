locals {
  resource_group_name = "rg-${var.name_prefix}"
  cluster_name        = "aks-${var.name_prefix}"

  # Tags are reused as node labels so that
  #   kubectl get nodes -L owner,env
  # answers "whose node is this?" without opening the portal.
  node_labels = var.tags
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = local.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  tags                = var.tags

  local_account_disabled = var.local_account_disabled

  default_node_pool {
    name                 = var.system_node_pool.name
    vm_size              = var.system_node_pool.vm_size
    os_disk_size_gb      = var.system_node_pool.os_disk_size_gb
    node_count           = var.system_node_pool.node_count
    node_labels          = local.node_labels
    auto_scaling_enabled = true
    min_count            = var.system_node_pool.min_count
    max_count            = var.system_node_pool.max_count

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = var.network_plugin
  }

  # Node count is owned by the cluster autoscaler at runtime. Without this,
  # every apply rewrites it back to the configured value and destroys nodes
  # that are actively running pods.
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  mode                  = "User"
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  node_count            = each.value.node_count
  auto_scaling_enabled  = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  node_taints           = each.value.node_taints
  node_labels           = merge(local.node_labels, each.value.node_labels)
  tags                  = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
