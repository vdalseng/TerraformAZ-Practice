variable "resource_group" {
  description = "The resource group information"
  type = object({
    name = string
    location = string
  })
}

variable "resource_name" {
    description = "The name of the resource"
    type        = string
}

variable "private_connection_resources" {
    description = "Map of private connection configurations"
    type = map(object({
        resource_id        = string
        subresource_names  = list(string)
    }))
}

variable "subnet_id" {
    description = "The ID of the subnet where the private endpoint will be created."
    type        = string
}

