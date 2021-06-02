variable "resource_group" {
  type        = string
  description = "The name of the resource group created for Garden Enterprise"
  default     = "garden-enterprise"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group created for Garden Enterprise"
  default     = "Germany West Central"
}

variable "aks_cluster_name" {
  type        = string
  description = "The name of the AKS cluster"
  default     = "garden-enterprise"
}

variable "database_server_name" {
  type        = string
  description = "The name of the postgres database server"
  default     = "garden-enterprise-postgres"
}

variable "database_name" {
  type        = string
  description = "The name of the database used for Garden Enterprise"
  default     = "garden-enterprise"
}

variable "database_admin_login" {
  type        = string
  description = "The admin user for your postgres server"
  default     = "postgres"
}

variable "database_admin_login_pw" {
  type        = string
  description = "The admin users password for your postgres server"
  default     = "8@7xLo*iDq3AePrmAdYXipmv"
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet used for the aks cluster"
  default     = "garden-enterprise-vnet"
}

variable "vault_name" {
  type        = string
  description = "The name of the Azure Key Vault"
  default     = "garden-enterprise-vault"
}

variable "app_client_secret" {
  type        = string
  description = "Client secret for accessing the Azure Key Vault"
  default     = "_G6Z-8ppcgCJGVDBA3npF4_r"
}
