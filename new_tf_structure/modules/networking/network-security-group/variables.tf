variable "network_security_group_name" {
  description = "The name of the network security group."
  type        = string
}

variable "location" {
  description = "The Azure region where the network security group will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the network security group will be created."
  type        = string
}

# variable "storage_account_address_spaces" {
#   description = "The address space for the storage account."
#   type        = list(string)
# }