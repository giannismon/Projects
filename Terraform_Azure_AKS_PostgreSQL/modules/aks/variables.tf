variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "app_identity_id" {
  type = string
}

variable "app_sa_namespace" {
  type    = string
  default = "default"
}

variable "app_sa_name" {
  type    = string
  default = "app-sa"
}
