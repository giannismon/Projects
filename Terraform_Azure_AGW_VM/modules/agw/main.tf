resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-p44010-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "waf-policy-p44010-${var.agw_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = var.waf_custom_rules

    content {
      name      = custom_rules.key
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type
      action    = custom_rules.value.action

      match_conditions {
        match_variables {
          variable_name = custom_rules.value.variable_name
        }

        operator           = custom_rules.value.operator
        negation_condition = custom_rules.value.negation_condition
        match_values       = custom_rules.value.match_values
      }
    }
  }

  policy_settings {
    enabled                     = var.waf_settings.enabled
    mode                        = var.waf_settings.mode
    request_body_check          = var.waf_settings.request_body_check
    file_upload_limit_in_mb     = var.waf_settings.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.waf_settings.max_request_body_size_in_kb
  }

  managed_rules {
    dynamic "managed_rule_set" {
      for_each = var.waf_managed_rule_sets

      content {
        type    = managed_rule_set.key
        version = managed_rule_set.value
      }
    }
  }
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-p44010-${var.agw_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = var.agw_subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports

    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates

    content {
      name                = ssl_certificate.key
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_pools

    content {
      name         = backend_address_pool.key
      ip_addresses = backend_address_pool.value.ip_addresses
      fqdns        = backend_address_pool.value.fqdns
    }
  }

  dynamic "probe" {
    for_each = var.probes

    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.host
      pick_host_name_from_backend_http_settings = probe.value.host == null
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      path                                = backend_http_settings.value.path
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.host_name == null ? backend_http_settings.value.pick_host_name_from_backend_address : false
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners

    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = local.frontend_ip_name
      frontend_port_name             = http_listener.value.frontend_port
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = http_listener.value.ssl_certificate
      host_name                      = http_listener.value.host_name
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirects

    content {
      name                 = redirect_configuration.key
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rules

    content {
      name                        = request_routing_rule.key
      rule_type                   = request_routing_rule.value.rule_type
      priority                    = request_routing_rule.value.priority
      http_listener_name          = request_routing_rule.value.listener
      backend_address_pool_name   = request_routing_rule.value.backend_pool
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings
      redirect_configuration_name = request_routing_rule.value.redirect
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for r in var.routing_rules : r.redirect != null || (r.backend_pool != null && r.backend_http_settings != null)])
      error_message = "Κάθε routing rule θέλει ή redirect ή backend_pool + backend_http_settings."
    }

    precondition {
      condition     = alltrue([for l in var.listeners : contains(keys(var.frontend_ports), l.frontend_port)])
      error_message = "Κάθε listener πρέπει να δείχνει σε frontend_port που υπάρχει στο frontend_ports."
    }

    precondition {
      condition     = alltrue([for r in var.routing_rules : contains(keys(var.listeners), r.listener)])
      error_message = "Κάθε routing rule πρέπει να δείχνει σε listener που υπάρχει στο listeners."
    }
  }
}
