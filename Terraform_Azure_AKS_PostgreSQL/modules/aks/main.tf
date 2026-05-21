resource "azurerm_kubernetes_cluster" "main" {
  name                      = "aks-${var.prefix}"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "aks-${var.prefix}"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = var.subnet_id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

}

# Links the AKS OIDC issuer to the managed identity for Workload Identity
resource "azurerm_federated_identity_credential" "app" {
  name                = "fed-app-${var.prefix}"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = var.app_identity_id
  subject             = "system:serviceaccount:${var.app_sa_namespace}:${var.app_sa_name}"
}
