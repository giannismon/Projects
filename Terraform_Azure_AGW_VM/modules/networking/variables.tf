variable "subnets" {
  description = <<-EOT
    Subnets of the VNet. The key is a stable logical name (vm, agw, bastion,
    data) and is the resource identity in state, so renaming a key means
    destroy and create. The Azure name defaults to subnet-<key>-monastiridis
    unless name is set explicitly, which the Bastion subnet needs: it MUST be
    called AzureBastionSubnet.
  EOT
  type = map(object({
    address_prefix    = string
    name              = optional(string)
    service_endpoints = optional(list(string))
  }))

  validation {
    condition     = length(distinct([for s in var.subnets : s.address_prefix])) == length(var.subnets)
    error_message = "Every subnet must have a unique address_prefix."
  }

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrnetmask(s.address_prefix))])
    error_message = "address_prefix must be valid CIDR, for example 10.0.1.0/24."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-monastiridis-main"
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "resource_group_name" {
  description = "Resource group of the network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}
