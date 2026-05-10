resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-p44010-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-p44010-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = var.agw_subnet_id
  }

  frontend_ip_configuration {
    name                 = "agw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  backend_address_pool {
    name         = "agw-backend-pool"
    ip_addresses = [var.vm_private_ip]
  }

  backend_http_settings {
    name                  = "agw-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "agw-listener"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "agw-routing-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "agw-listener"
    backend_address_pool_name  = "agw-backend-pool"
    backend_http_settings_name = "agw-http-settings"
  }
}
