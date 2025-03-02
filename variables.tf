variable "admin_username" {
  description = "virtual machine admin username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "virtual machine admin password"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "the azure subscription id"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "the azure client id"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "the azure tenant id"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "the azure client secret"
  type        = string
  sensitive   = true
}