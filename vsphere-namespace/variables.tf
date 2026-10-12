variable "vcenter_server" {
  type        = string
  description = "The vCenter address"
}

variable "vcenter_user" {
  type        = string
  description = "A vCenter user that can create supervisor namespaces"
}

variable "vcenter_password" {
  type        = string
  description = "The password for the vCenter user"
  sensitive   = true
}

variable "supervisor_endpoint" {
  type        = string
  description = "The address of the supervisor control plane"
}

variable "supervisor_id" {
  type        = string
  description = "The id of the supervisor, from vCenter"
}

variable "storage_policy_name" {
  type        = string
  description = "The vCenter storage policy that the namespace can use"
}

variable "namespace_name" {
  type        = string
  description = "The name of the supervisor namespace"
  default     = "tf-example"
}
