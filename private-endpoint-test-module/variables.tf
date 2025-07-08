variable "resource_group_name" {
    description = "The name of the resource."
    type        = string
}

variable "resource_group_location" {
    description = "The Azure region where the resource group will be created."
    type        = string
}

variable "resource_name" {
    description = "The name of the resource."
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to the resource."
    type        = map(string)
    default     = {}
}

variable "subresource_name" {
    description = "The name of the sub-resource (e.g., 'blob', 'queue', 'table')"
    type        = string
    default     = "blob"
}