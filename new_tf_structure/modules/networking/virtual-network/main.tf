// Virtual Network is a representation of your own network in Azure
// It can be used to connect different resources like VMs, databases, etc.
resource "azurerm_virtual_network" "vnet" {
    name                = var.virtual_network_name
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = var.address_space
    dns_servers         = var.dns_servers

    tags                = var.tags

    # Subnets can be added below
}