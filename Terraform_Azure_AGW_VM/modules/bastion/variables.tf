variable "bastion_subnet_id" {
  description = "Id του AzureBastionSubnet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group του Bastion."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags στο Bastion και στο public IP."
  type        = map(string)
  default     = {}
}
