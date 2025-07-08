resource "azurerm_subnet" "subnet" {
    name                    = var.subnet_name
    resource_group_name     = var.resource_group_name
    virtual_network_name    = var.virtual_network_name
    address_prefixes        = [var.address_prefix]

    private_endpoint_network_policies               = "Disabled"
    private_link_service_network_policies_enabled   = false
}

resource "azurerm_subnet" "bastion_subnet" {
    name                    = "AzureBastionSubnet"
    resource_group_name     = var.resource_group_name
    virtual_network_name    = var.virtual_network_name
    address_prefixes        = [var.bastion_subnet_address_prefix]
}