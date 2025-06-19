variable "resource_name" {
  description = "The name of the resource"
  type        = string
}

variable "location" {
  description = "The Azure location where the resource group will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource group."
  type        = map(string)
  default     = {}
}

variable "storage_account_names" {
  description = "List of storage account suffixes"
  type        = list(string)
  default     = ["primary", "secondary"]
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = string
}