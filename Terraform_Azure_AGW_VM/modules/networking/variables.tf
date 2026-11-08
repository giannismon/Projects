variable "subnets" {
  description = <<-EOT
    Subnets του vnet. Το key είναι σταθερό logical name (vm, agw, bastion, data)
    και καθορίζει την ταυτότητα στο state — μετονομασία key σημαίνει destroy/create.
    Το Azure name παράγεται ως subnet-<key>-p44010, εκτός αν δοθεί ρητά το name
    (π.χ. το bastion subnet ΠΡΕΠΕΙ να λέγεται AzureBastionSubnet).
  EOT
  type = map(object({
    address_prefix    = string
    name              = optional(string)
    service_endpoints = optional(list(string))
  }))

  validation {
    condition     = length(distinct([for s in var.subnets : s.address_prefix])) == length(var.subnets)
    error_message = "Κάθε subnet πρέπει να έχει μοναδικό address_prefix."
  }

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrnetmask(s.address_prefix))])
    error_message = "Το address_prefix πρέπει να είναι έγκυρο CIDR (π.χ. 10.0.1.0/24)."
  }
}

variable "vnet_name" {
  description = "Όνομα του virtual network."
  type        = string
  default     = "vnet-p44010-main"
}

variable "address_space" {
  description = "Address space του vnet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "resource_group_name" {
  description = "Resource group του δικτύου."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags στο vnet."
  type        = map(string)
  default     = {}
}
