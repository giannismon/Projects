variable "kv_name" {
  description = "Όνομα του Key Vault (globally unique, το soft-delete κρατά το όνομα δεσμευμένο)."
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Secrets: key = όνομα του secret στο vault, value = η τιμή.
    Η variable ΔΕΝ είναι declared sensitive: τότε ολόκληρη η map θα ήταν sensitive
    και το for_each θα έσκαγε με "Invalid for_each argument". Το να περάσεις
    sensitive τιμή μέσα στη map είναι εντάξει — το resource τη ξανα-μαρκάρει με
    sensitive(), οπότε δεν εμφανίζεται στο plan.
  EOT
  type = map(object({
    value        = string
    content_type = optional(string)
  }))
  default = {}
}

variable "certificates" {
  description = "Self-signed certificates. Key = όνομα του certificate στο vault."
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
    Access policies πέρα από του deployer. Key = logical name (agw, app, ops).
    Οι τιμές είναι λίστες permissions του Key Vault.
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
  description = "Αν θα δοθεί full secret/certificate access στην identity που τρέχει το Terraform."
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "SKU του Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Το sku_name πρέπει να είναι standard ή premium."
  }
}

variable "resource_group_name" {
  description = "Resource group του Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags στο Key Vault."
  type        = map(string)
  default     = {}
}
