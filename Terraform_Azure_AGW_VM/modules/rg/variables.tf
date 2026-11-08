# Ένα resource group ανά environment — όλα τα modules κρεμάνε από αυτό.
# Map εδώ θα σήμαινε module.rg.rg_names["main"] σε ~15 σημεία για μηδέν κέρδος.
variable "rg_name" {
  description = "Όνομα του resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags στο resource group."
  type        = map(string)
  default     = {}
}
