variable "agw_name" {
  description = "Logical name of the gateway, used in the Azure names (agw-monastiridis-<name>)."
  type        = string
}

variable "backend_pools" {
  description = "Backend pools. The key is the pool name that routing rules reference."
  type = map(object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
}

variable "frontend_ports" {
  description = "Frontend ports: key = name, value = port number."
  type        = map(number)
  default = {
    "port-80"  = 80
    "port-443" = 443
  }
}

variable "ssl_certificates" {
  description = "SSL certificates from Key Vault. The key is the name that listeners reference."
  type = map(object({
    key_vault_secret_id = string
  }))
  default = {}
}

variable "backend_http_settings" {
  description = "Backend HTTP settings. The key is the name that routing rules reference."
  type = map(object({
    port                                = optional(number, 80)
    protocol                            = optional(string, "Http")
    cookie_based_affinity               = optional(string, "Disabled")
    request_timeout                     = optional(number, 30)
    path                                = optional(string)
    probe_name                          = optional(string)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
  }))
  default = {
    "agw-http-settings" = {}
  }
}

variable "probes" {
  description = "Health probes. The key is the name that probe_name on the settings references."
  type = map(object({
    path                = string
    protocol            = optional(string, "Http")
    host                = optional(string)
    interval            = optional(number, 30)
    timeout             = optional(number, 30)
    unhealthy_threshold = optional(number, 3)
  }))
  default = {}
}

variable "listeners" {
  description = "HTTP listeners. The key is the name that routing rules reference."
  type = map(object({
    frontend_port   = string
    protocol        = optional(string, "Http")
    ssl_certificate = optional(string)
    host_name       = optional(string)
  }))
  default = {
    "listener-http" = {
      frontend_port = "port-80"
      protocol      = "Http"
    }
    "listener-https" = {
      frontend_port   = "port-443"
      protocol        = "Https"
      ssl_certificate = "agw-ssl-cert"
    }
  }
}

variable "redirects" {
  description = "Redirect configurations. The key is the name that routing rules reference."
  type = map(object({
    target_listener      = string
    redirect_type        = optional(string, "Permanent")
    include_path         = optional(bool, true)
    include_query_string = optional(bool, true)
  }))
  default = {
    "redirect-http-to-https" = {
      target_listener = "listener-https"
    }
  }
}

variable "routing_rules" {
  description = <<-EOT
    Request routing rules, keyed by rule name.
    Every rule needs either a redirect, or a backend_pool together with
    backend_http_settings.
  EOT
  type = map(object({
    priority              = number
    listener              = string
    backend_pool          = optional(string)
    backend_http_settings = optional(string)
    redirect              = optional(string)
    rule_type             = optional(string, "Basic")
  }))
  default = {
    "rule-http-redirect" = {
      priority = 100
      listener = "listener-http"
      redirect = "redirect-http-to-https"
    }
    "rule-https" = {
      priority              = 200
      listener              = "listener-https"
      backend_pool          = "agw-backend-pool"
      backend_http_settings = "agw-http-settings"
    }
  }

  validation {
    condition     = length(distinct([for r in var.routing_rules : r.priority])) == length(var.routing_rules)
    error_message = "Every routing rule must have a unique priority."
  }
}

variable "sku" {
  description = "SKU of the gateway."
  type = object({
    name     = optional(string, "WAF_v2")
    tier     = optional(string, "WAF_v2")
    capacity = optional(number, 1)
  })
  default = {}
}

variable "ssl_policy_name" {
  description = "Predefined SSL policy."
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "waf_custom_rules" {
  description = "WAF custom rules, keyed by rule name."
  type = map(object({
    priority           = number
    action             = string
    variable_name      = string
    operator           = string
    match_values       = list(string)
    rule_type          = optional(string, "MatchRule")
    negation_condition = optional(bool, false)
  }))
  default = {
    "DenySpecificIP" = {
      priority      = 1
      action        = "Block"
      variable_name = "RemoteAddr"
      operator      = "IPMatch"
      match_values  = ["203.0.113.99/32"]
    }
  }

  validation {
    condition     = length(distinct([for r in var.waf_custom_rules : r.priority])) == length(var.waf_custom_rules)
    error_message = "Every WAF custom rule must have a unique priority."
  }
}

variable "waf_managed_rule_sets" {
  description = "Managed rule sets: key = rule set type, value = version."
  type        = map(string)
  default = {
    "OWASP" = "3.2"
  }
}

variable "waf_settings" {
  description = "Policy settings of the WAF."
  type = object({
    enabled                     = optional(bool, true)
    mode                        = optional(string, "Prevention")
    request_body_check          = optional(bool, true)
    file_upload_limit_in_mb     = optional(number, 100)
    max_request_body_size_in_kb = optional(number, 128)
  })
  default = {}
}

variable "agw_subnet_id" {
  description = "Subnet of the gateway, dedicated to the Application Gateway."
  type        = string
}

variable "identity_id" {
  description = "User assigned identity that reads the certificate from Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the gateway."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the gateway, its public IP and the WAF policy."
  type        = map(string)
  default     = {}
}
