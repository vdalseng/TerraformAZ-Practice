variable "environments" {
    description = "A list of environments to create Key Vaults for."
    type        = list(string)
}

variable "key_vault_name" {
    description = "The name of the Key Vault resource."
    type        = string
}

variable "location" {
    description = "The region to create the resource"
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group."
    type        = string
}

variable "sku_name" {
    description = "The SKU name for the Key Vault."
    type        = string
    default     = "standard"
}

variable "tenant_id" {
    description = "The tenant ID for the Key Vault access policy."
    type        = string
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

variable tags {
    description = "A map of tags to assign to the resource group."
    type        = map(string)
}

variable "object_id" {
    description = "The object ID for the Key Vault access policy."
    type        = string
    default     = null
}

variable "key_permissions" {
    description = "The permissions for keys in the Key Vault."
    type        = list(string)
    default     = ["Get"]
}

variable "secret_permissions" {
    description = "The permissions for secrets in the Key Vault."
    type        = list(string)
    default     = ["Get", "Set", "Delete"]
}

variable "storage_permissions" {
    description = "The permissions for storage in the Key Vault."
    type        = list(string)
    default     = ["Get"]
  
}

variable "key_vault_secret_name" {
    description = "The name of the Key Vault secret to create."
    type        = string
}

variable "value" {
    description = "The value of the Key Vault secret."
    type        = string
    default     = null
}