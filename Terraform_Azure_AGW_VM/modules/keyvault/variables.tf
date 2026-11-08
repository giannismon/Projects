variable "kv_name" {
  description = "Name of the Key Vault: globally unique, and soft-delete keeps the name reserved after deletion."
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Secrets: key = the secret name in the vault, value = the secret value.
    The variable is NOT declared sensitive: that would make the whole map
    sensitive and for_each would fail with "Invalid for_each argument".
    Passing a sensitive value inside the map is fine, the resource re-marks it
    with sensitive() so it does not show up in the plan.
  EOT
  type = map(object({
    value        = string
    content_type = optional(string)
  }))
  default = {}
}

variable "certificates" {
  description = "Self-signed certificates. The key is the certificate name in the vault."
  type = map(object({
    subject            = string
    validity_in_months = optional(number, 12)
    days_before_expiry = optional(number, 30)
    key_size           = optional(number, 2048)
    issuer             = optional(string, "Self")
    dns_names          = optional(list(string), [])
    extended_key_usage = optional(list(string), ["1.3.6.1.5.5.7.3.1"])
    key_usage = optional(list(string), [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyAgreement",
      "keyCertSign",
      "keyEncipherment",
    ])
  }))
  default = {}
}

variable "access_policies" {
  description = <<-EOT
    Access policies on top of the deployer's own. The key is a logical name
    (agw, app, ops) and the values are Key Vault permission lists.
  EOT
  type = map(object({
    object_id               = string
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
  }))
  default = {}
}

variable "grant_deployer_access" {
  description = "Whether the identity running Terraform gets full secret and certificate access."
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "SKU of the Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "resource_group_name" {
  description = "Resource group of the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Key Vault."
  type        = map(string)
  default     = {}
}
