variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "suffix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tf_principal_id" {
  type = string
}

variable "app_identity_principal_id" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}
