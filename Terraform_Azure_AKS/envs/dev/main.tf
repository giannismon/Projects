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
  tags                = var.tags

  # Dev: no SLA, and the local admin account stays enabled so that
  # az aks get-credentials keeps working.
  sku_tier               = "Free"
  local_account_disabled = false

  # The system pool cannot be a module: it is a block inside the cluster
  # resource itself, not a standalone resource. Only user pools are.
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
    network_plugin = "azure"
  }

  # Node count is owned by the cluster autoscaler at runtime.
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# The only module: one user node pool per call.
module "node_pool" {
  source   = "../../modules/nodepool"
  for_each = var.user_node_pools

  cluster_id    = azurerm_kubernetes_cluster.this.id
  name          = each.key
  pool          = each.value
  common_labels = local.node_labels
  tags          = var.tags
}
