variable "rg_name" {
  type    = string
  default = "rg-p44010-prod"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "kv_name" {
  type    = string
  default = "kv-p44010-prod"
}

variable "vm_name" {
  type    = string
  default = "prod"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "private_ip" {
  type    = string
  default = "10.0.1.10"
}

variable "disk_size_gb" {
  type    = number
  default = 100
}

variable "disk_type" {
  type    = string
  default = "Premium_LRS"
}

variable "disk2_size_gb" {
  type    = number
  default = 50
}

variable "disk2_type" {
  type    = string
  default = "Premium_LRS"
}
