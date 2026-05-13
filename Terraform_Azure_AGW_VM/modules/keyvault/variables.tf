variable "kv_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "agw_principal_id" {
  type = string
}
