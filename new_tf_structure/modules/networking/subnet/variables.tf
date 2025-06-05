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

variable "service_endpoints" {
    description = "A list of service endpoints to enable for the subnet."
    type        = list(string)
    default     = []
}

variable "network_security_group_id" {
    description = "The ID of the network security group to associate with the subnet."
    type        = string
}