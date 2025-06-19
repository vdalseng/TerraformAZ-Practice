variable "vnet_canonical_name" {
}

variable "environment" {
}


variable "resource_group" {
  description = "The name of resource group."
}

variable "name_override" {
  description = "Set this to force a name of the resource. Should normally not be used. "
  default     = ""
}

variable "subnet_configs" {
  description = "Map over the subnets that will be created. Key is the subnet name. Value is the address space of this subnet."
  type        = map(string)
}

variable "nsg_attached_subnets" {
  description = "A set with the names of subnets as defined in subnet_configs that are to be attached to the NSG."
  type        = set(string)
}

variable "system_name" {
  description = "Required. The name for the system. For example, mmm or idgen."
}

variable "address_space" {
  description = "The address space that is used the virtual network.You can supply more than one address space."
  type        = list(string)
}
variable "dns_servers" {
  description = "(Optional) List of DNS Servers configured in the VNET"
  default     = []
}

variable "nsg_rules" {
  description = "An NSG will be created attached to all subnets in this vNet. This is a map of the rules to be added to this NSG. `source_address_prefixes` and `destination_address_prefixes` can be lists of IP-ranges or the names of subnets as defined in var.subnet_configs, or a combination thereof. Refer to the terraform docs for the resource `azurerm_network_security_rule` for further explanation of the values."
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_ranges           = list(string)
    destination_port_ranges      = list(string)
    source_address_prefixes      = list(string)
    destination_address_prefixes = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_network_policies" {
  type    = string
  default = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "private_endpoint_network_policies must be either 'Disabled', 'Enabled', 'NetworkSecurityGroupEnabled' or 'RouteTableEnabled'."
  }
}

variable "ddos_protection_plan_id" {
  default = null
}