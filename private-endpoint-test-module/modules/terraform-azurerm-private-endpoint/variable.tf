variable "resource_name" {
    description = "The name of the resource"
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group where the private endpoint will be created"
    type        = string
}

variable "resource_group_location" {
    description = "The Azure region where the private endpoint will be created"
    type        = string
}

variable "resource_id" {
    description = "The ID of the resource to which the private endpoint will connect"
    type        = string
}

variable "subresource_name" {
    description = "The name of the sub-resource (e.g., 'blob', 'queue', 'table')"
    type        = string
    default     = "blob"

    validation {
        condition       = contains(["blob", "queue", "table", "file", "sql", "cosmosdb", "keyvault", "redis", var.subresource_name])
        error_message   = "subresource_names must either 'blob', 'queue', 'table', 'file', 'sql', 'cosmosdb', 'keyvault', or 'redis'."
  }
}

variable "private_endpoint_subnet_id" {
    description = "The ID of the subnet where the private endpoint will be created. Must have private_endpoint_network_policies disabled."
    type        = string
}

variable "private_dns_zone_id" {
  description   = "Private DNS zone ID to link with the private endpoint (optional - for DNS integration)"
  type          = string
  default       = null
}

variable "tags" {
    description = "A map of tags to assign to the private endpoint"
    type        = map(string)
    default     = {}
  
}