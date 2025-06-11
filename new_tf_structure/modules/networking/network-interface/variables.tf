
variable "network_interface_name" {
    description = "The name of the network interface."
    type        = string
}

variable "location" {
    description = "The Azure region where the network interface will be created."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group where the network interface will be created."
    type        = string
}

variable "subnet_id" {
    description = "The ID of the subnet where the network interface will be created."
    type        = string
}

variable "private_ip_address_allocation" {
    description = "The allocation method for the private IP address (Dynamic or Static)."
    type        = string
    default     = "Dynamic"
    
    validation {
        condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
        error_message = "The private_ip_address_allocation must be either 'Dynamic' or 'Static'."
    }
}

variable "private_ip_address" {
    description = "The static private IP address to assign (only used if allocation is Static)."
    type        = string
    default     = null
}

variable "public_ip_address_id" {
    description = "The ID of the public IP address to associate with the network interface."
    type        = string
    default     = null
}

variable "tags" {
    description = "Tags to be applied to the network interface."
    type        = map(string)
    default     = {}
}
