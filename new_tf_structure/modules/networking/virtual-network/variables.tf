variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "location" {
  description = "The Azure region where the virtual network will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the virtual network will be created."
  type        = string
}

variable "network_security_group_id" {
  description = "The ID of the network security group to associate with the virtual network."
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network in CIDR notation."
  type        = list(string)
}

variable "dns_servers" {
  description = "A list of DNS server IP addresses for the virtual network."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the virtual network."
  type        = map(string)
  default     = {}
}