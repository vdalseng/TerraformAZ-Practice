variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "4d44263b-1bf2-4919-9046-1a108c92b127"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vetle-private-networking-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "North Europe"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "vetlesa"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

variable "key_vault_name_prefix" {
  description = "Prefix for the Key Vault name"
  type        = string
  default     = "vetlekv"
}
