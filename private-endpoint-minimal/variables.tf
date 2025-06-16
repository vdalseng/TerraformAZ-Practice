variable "name" {
  description   = "Name of the private endpoint"
  type          = string
}

variable "location" {
  description   = "Azure region"
  type          = string
}

variable "resource_group_name" {
  description   = "Resource group name"
  type          = string
}

variable "subnet_id" {
  description   = "Subnet ID for private endpoint (must have private_endpoint_network_policies disabled)"
  type          = string
}

variable "target_resource_id" {
  description   = "Resource ID of the target Azure service"
  type          = string
}

variable "subresource_names" {
  description   = "Subresource names for the private endpoint (e.g., ['blob'] for storage)"
  type          = list(string)
  default       = ["blob"]
  
  validation {
    condition       = contains(["blob", "queue", "table", "file", "sql", "cosmosdb", "keyvault", "redis",])
    error_message   = "subresource_names must either 'blob', 'queue', 'table', 'file', 'sql', 'cosmosdb', 'keyvault', or 'redis'."
  }
}

variable "private_dns_zone_id" {
  description   = "Private DNS zone ID (optional - for DNS integration)"
  type          = string
  default       = null
}

variable "tags" {
  description   = "Tags to apply to resources"
  type          = map(string)
  default       = {}
}
