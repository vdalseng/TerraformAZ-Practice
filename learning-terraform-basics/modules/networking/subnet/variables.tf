variable "subnet_name" {
    description = "The name of the subnet."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group where the subnet will be created."
    type        = string
}

variable "virtual_network_name" {
    description = "The name of the virtual network to which the subnet belongs."
    type        = string
}

variable "address_prefix" {
    description = "The address prefix for the subnet."
    type        = string
}

variable "bastion_subnet_address_prefix" {
    description = "The address prefix for the bastion subnet."
    type        = string
}