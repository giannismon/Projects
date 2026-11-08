# One resource group per environment: every other module hangs off it.
# A map here would mean module.rg.rg_names["main"] in ~15 places for no gain.
variable "rg_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group."
  type        = map(string)
  default     = {}
}
