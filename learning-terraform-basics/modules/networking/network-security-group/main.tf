// NSG can be configured to control inbound and outbound traffic for specified subnets
resource "azurerm_network_security_group" "network-security-group" {
    name                = var.network_security_group_name
    location            = var.location
    resource_group_name = var.resource_group_name

    security_rule {
        name                       = "AllowBastionManagement"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "3389"]
        source_address_prefix      = "10.133.99.128/25"  # Bastion subnet
        destination_address_prefix = "10.133.99.0/25"    # VM and Private Endpoint subnet
        description                = "Allow management traffic from Azure Bastion to VMs"
    }

    security_rule {
        name                       = "DenyInternetManagement"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "3389", "5985", "5986"]
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    }
}