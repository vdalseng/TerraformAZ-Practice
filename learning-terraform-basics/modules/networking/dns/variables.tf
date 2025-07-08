variable "resource_group_name" {
    description = "The name of the resource group where the DNS zone will be created."
    type        = string
}

variable "virtual_network_id" {
    description = "The ID of the virtual network to link to the private DNS zone"
    type        = string
}

variable "service_type" {
    description = "The Azure service type for the private DNS zone"
    type        = string
    default     = "blob"
}

variable "azure_environment" {
    description = "Azure environment (core.windows.net, etc.)"
    type        = string
    default     = "core.windows.net"
}

variable "tags" {
    description = "A map of tags to assign to the resource"
    type        = map(string)
    default     = {}
}