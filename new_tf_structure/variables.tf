variable "resource_group_name" {
    description = "The name of the resource group."
    type        = string
}

variable "location" {
    description = "The region to create the resource"
    type        = string
}

variable "storage_account_name" {
    description = "The name of the storage account."
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to the storage account."
    type        = map(string)
    default     = {}
}

variable "account_tier" {
    description = "The tier of the storage account."
    type        = string
    default     = "Standard"
}

variable "account_replication_type" {
    description = "The replication type of the storage account."
    type        = string
    default     = "LRS"
}

variable "key_vault_name" {
    description = "The name of the Key Vault."
    type        = string
}

variable "sku_name" {
    description = "The SKU name for the Key Vault."
    type        = string
    default     = "standard"
}

variable "enabled_for_disk_encryption" {
    description = "Whether the Key Vault is enabled for disk encryption."
    type        = bool
    default     = true
}

variable "soft_delete_retention_days" {
    description = "The number of days to retain soft-deleted Key Vaults."
    type        = number
    default     = 7
}

variable "purge_protection_enabled" {
    description = "Whether purge protection is enabled for the Key Vault."
    type        = bool
    default     = false
}

variable "environments" {
    description = "A list of environments for which the Key Vault should be created."
    type        = list(string)
}

variable "key_permissions" {
    description = "The permissions for keys in the Key Vault."
    type        = list(string)
}

variable "secret_permissions" {
    description = "The permissions for secrets in the Key Vault."
    type        = list(string)
}

variable "storage_permissions" {
    description = "The permissions for storage in the Key Vault."
    type        = list(string)
}

variable "key_vault_secret_name" {
    description = "The name of the Key Vault secret."
    type        = string
}