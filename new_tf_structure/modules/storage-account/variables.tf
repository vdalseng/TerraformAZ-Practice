variable "storage_account_name" {
    description = "The name of the resource group."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group."
    type        = string
}

variable "location" {
    description = "The region to create the resource"
    type        = string
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

variable tags {
    description = "A map of tags to assign to the resource group."
    type        = map(string)
}

variable "allowed_subnet_ids" {
    description = "List of subnet IDs that should have access to the storage account"
    type        = list(string)
    default     = []
}