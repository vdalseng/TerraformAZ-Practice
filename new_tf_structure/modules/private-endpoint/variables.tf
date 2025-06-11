variable "private_endpoint_name" {
    description = "The name of the private endpoint."
    type        = string
}

variable "location" {
    description = "The Azure region where the private endpoint will be created."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group where the private endpoint will be created."
    type        = string
}

variable "subnet_id" {
    description = "The ID of the subnet where the private endpoint will be created."
    type        = string
}

variable "private_service_connection_name" {
    description = "The name of the private service connection."
    type        = string
}

variable "private_connection_resource_id" {
    description = "The resource ID of the service to which the private endpoint connects."
    type        = string
}

variable "subresource_names" {
    description = "The names of the subresources for the private service connection."
    type        = list(string)
}

variable "dns_zone_group_name" {
    description = "The name of the DNS zone group for the private endpoint."
    type        = string
}

variable "private_dns_zone_ids" {
    description = "The IDs of the private DNS zones to associate with the private endpoint."
    type        = list(string)
}

variable "tags" {
    description = "Tags to be applied to the private endpoint."
    type        = map(string)
    default     = {}
}