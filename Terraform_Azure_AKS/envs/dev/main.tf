module "aks" {
  source = "../../modules/aks"

  name_prefix        = var.name_prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  tags               = var.tags

  system_node_pool = var.system_node_pool
  user_node_pools  = var.user_node_pools

  # Dev: no SLA, and the local admin account stays enabled so that
  # az aks get-credentials keeps working.
  sku_tier               = "Free"
  local_account_disabled = false
}
