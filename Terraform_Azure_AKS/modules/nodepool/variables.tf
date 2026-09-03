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

variable "mode" {
  description = "User for application workloads. System only for additional system pools."
  type        = string
  default     = "User"

  validation {
    condition     = contains(["User", "System"], var.mode)
    error_message = "mode must be User or System."
  }
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "os_disk_size_gb" {
  type    = number
  default = 50
}

variable "node_count" {
  description = "Initial node count. Owned by the autoscaler afterwards — see ignore_changes."
  type        = number
  default     = 1
}

variable "min_count" {
  type    = number
  default = 1
}

variable "max_count" {
  type    = number
  default = 3
}

variable "node_labels" {
  description = "Kubernetes node labels, used by nodeSelector"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Node taints, e.g. [\"dedicated=db:NoSchedule\"]. Changing them recreates the pool."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Azure resource tags (distinct from Kubernetes node labels)"
  type        = map(string)
  default     = {}
}
