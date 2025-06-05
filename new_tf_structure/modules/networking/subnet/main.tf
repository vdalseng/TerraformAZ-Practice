resource "azurerm_subnet" "subnet" {
    name                    = var.subnet_name
    resource_group_name     = var.resource_group_name
    virtual_network_name    = var.virtual_network_name
    address_prefixes        = [var.address_prefix]

    # Service Endpoints
    service_endpoints       = var.service_endpoints
}

resource "azurerm_subnet" "bastion_subnet" {
    name                    = "bastion-subnet"
    resource_group_name     = var.resource_group_name
    virtual_network_name    = var.virtual_network_name
    address_prefixes        = [var.bastion_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
    subnet_id                   = azurerm_subnet.subnet.id
    network_security_group_id   = var.network_security_group_id
}