// Virtual Network is a representation of your own network in Azure
// It can be used to connect different resources like VMs, databases, etc.
resource "azurerm_virtual_network" "vnet" {
    name                    = var.virtual_network_name
    location                = var.location
    resource_group_name     = var.resource_group_name
    address_space           = var.address_space
    # dns_servers             = var.dns_servers

    tags                    = var.tags
}

resource "azurerm_public_ip" "pip" {
    name                    = "${var.virtual_network_name}-pip"
    location                = var.location
    resource_group_name     = var.resource_group_name
    allocation_method       = var.allocation_method
    sku                     = var.sku
}

resource "azurerm_bastion_host" "bastion" {
    name                    = "${var.virtual_network_name}-bastion"
    location                = var.location
    resource_group_name     = var.resource_group_name
    
    ip_configuration {
        name                    = "${var.virtual_network_name}-bastion-ipconfig"
        subnet_id               = var.bastion_subnet_id
        public_ip_address_id    = azurerm_public_ip.pip.id
    }
}