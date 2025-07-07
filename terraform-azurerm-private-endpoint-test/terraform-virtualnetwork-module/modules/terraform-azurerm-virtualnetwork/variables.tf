variable "vnet_canonical_name" {
  description = "The canonical name for the virtual network"
  type        = string
}

variable "system_name" {
  description = "Required. The name for the system."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, test, prod)"
  type        = string
}

variable "resource_group" {
  description = "The name of resource group."
}

variable "name_override" {
  description = "Set this to force a name of the resource. Should normally not be used."
  type        = string
  default     = ""
}

variable "address_space" {
  description = "The address space that is used the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "dns_servers" {
  description = "(Optional) List of DNS Servers configured in the VNET"
  type        = list(string)
  default     = []
}

variable "subnet_configs" {
  description = "Map over the subnets that will be created. Key is the subnet name. Value is the address space of this subnet."
  type        = map(string)
  default     = {}
}

variable "nsg_attached_subnets" {
  description = "A set with the names of subnets as defined in subnet_configs that are to be attached to the NSG."
  type        = set(string)
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
  description = <<EOF
    Network policies for private endpoints on subnets. Private endpoints rank higher than nsg for routing traffic.
    Enabling this can cause issues with private endpoints if not configured correctly. 
    Options are 'Disabled', 'Enabled', 'NetworkSecurityGroupEnabled', or 'RouteTableEnabled'.
    EOF
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "private_endpoint_network_policies must be either 'Disabled', 'Enabled', 'NetworkSecurityGroupEnabled' or 'RouteTableEnabled'."
  }
}

variable "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan to associate with the VNet"
  type        = string
  default     = null
}

variable "private_endpoint_configs" {
  description = "Map of private endpoint configurations. Key is used as identifier. Only essential inputs required - names and connections are auto-generated."
  type = map(object({
    subnet_name         = string
    resource_id         = string
    subresource_names   = list(string)
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }))
  }))
  default = {}
}

variable "create_dns_zones" {
  description = "Whether this module instance should create DNS zones. Set to false if another instance will create them."
  type        = bool
  default     = true
}

variable "shared_dns_zone_ids" {
  description = "Map of shared DNS zone IDs from other module instances. Key should match the zone name with dots replaced by underscores."
  type        = map(string)
  default     = {}
}