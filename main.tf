resource "azurerm_resource_group" "resource_group" {
    name        = var.resource_group_name
    location    = var.resource_group_location
    tags        = var.tags
}

resource "azurerm_storage_account" "storage_account" {
    name                     = var.resource_name
    resource_group_name      = azurerm_resource_group.resource_group.name
    location                 = azurerm_resource_group.resource_group.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    public_network_access_enabled   = false

    tags                            = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name                = "${var.resource_name}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    tags                = var.tags
}

resource "azurerm_subnet" "private_endpoint_subnet" {
    name                 = "${var.resource_name}-private-endpoint-subnet"
    resource_group_name  = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.0.0/24"]
}

module "private-endpoint" {
    source                      = "./terraform-azurerm-private-endpoint"
    resource_name               = var.resource_name
    resource_group_name         = var.resource_group_name
    resource_group_location     = var.resource_group_location
    resource_id                 = azurerm_storage_account.storage_account.id
    subresource_name            = var.subresource_name
    private_endpoint_subnet_id  = azurerm_subnet.private_endpoint_subnet.id
    # private_dns_zone_id         = var.private_dns_zone_id
    tags                        = var.tags
}