variable "cluster_id" {
  description = "ID of the AKS cluster this pool attaches to"
  type        = string
}

variable "name" {
  description = "Pool name. Lowercase, max 12 characters for Linux pools."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,11}$", var.name))
    error_message = "Node pool name must be lowercase alphanumeric, start with a letter, max 12 characters."
  }
}

variable "pool" {
  description = <<-EOT
    The whole pool description as one object. Every field is optional — anything
    left out takes the default shown here.

    node_taints: changing them RECREATES the pool.
  EOT

  type = object({
    mode            = optional(string, "User")
    vm_size         = optional(string, "Standard_D2s_v3")
    os_disk_size_gb = optional(number, 50)
    node_count      = optional(number, 1)
    min_count       = optional(number, 1)
    max_count       = optional(number, 3)
    node_labels     = optional(map(string), {})
    node_taints     = optional(list(string), [])
  })
  default = {}

  validation {
    condition     = contains(["User", "System"], var.pool.mode)
    error_message = "pool.mode must be User or System."
  }
}

variable "common_labels" {
  description = "Labels shared by every pool; merged with pool.node_labels"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Azure resource tags (distinct from Kubernetes node labels)"
  type        = map(string)
  default     = {}
}
