resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-ioannis-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "waf-policy-ioannis"
  resource_group_name = var.resource_group_name
  location            = var.location

  custom_rules {
    name      = "DenySpecificIP"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "IPMatch"
      negation_condition = false
      match_values       = [var.blocked_ip]
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-ioannis-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
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

  frontend_port {
    name = "port-443"
    port = 443
  }

  ssl_certificate {
    name                = "agw-ssl-cert"
    key_vault_secret_id = var.ssl_certificate_secret_id
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
    name                           = "listener-http"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "agw-ssl-cert"
  }

  redirect_configuration {
    name                 = "redirect-http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "listener-https"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "rule-http-redirect"
    rule_type                   = "Basic"
    priority                    = 100
    http_listener_name          = "listener-http"
    redirect_configuration_name = "redirect-http-to-https"
  }

  request_routing_rule {
    name                       = "rule-https"
    rule_type                  = "Basic"
    priority                   = 200
    http_listener_name         = "listener-https"
    backend_address_pool_name  = "agw-backend-pool"
    backend_http_settings_name = "agw-http-settings"
  }
}
