variable "bastion_subnet_id" {
  description = "Id of the AzureBastionSubnet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the Bastion host."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Bastion host and its public IP."
  type        = map(string)
  default     = {}
}
