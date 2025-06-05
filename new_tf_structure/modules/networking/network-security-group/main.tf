// NSG can be configured to control inbound and outbound traffic for specified subnets
resource "azurerm_network_security_group" "network-security-group" {
    name                = var.network_security_group_name
    location            = var.location
    resource_group_name = var.resource_group_name
    
    // Security rules define the access control for the NSG
    # Network Security Group Rule for allowing access to storage accounts
    # security_rule {
    #     name                            = "AllowVirtualNetworkInbound"
    #     priority                        = 100
    #     direction                       = "Inbound"
    #     access                          = "Allow"
    #     protocol                        = "Any"
    #     source_port_range               = "*"
    #     destination_port_range          = "*"
    #     source_address_prefixes         = ["VirtualNetwork"]
    #     destination_address_prefixes    = var.storage_account_address_spaces
    # }

    # Security Rule for allowing access to Azure services

    # Network Security Group Rule for Private Endpoints
    # security_rule {
    #     name                            = "AllowPrivateEndpointInbound"
    #     priority                        = 200
    #     direction                       = "Inbound"
    #     access                          = "Allow"
    #     protocol                        = "Tcp"
    #     source_port_range               = "*"
    #     destination_port_range          = ["80","443"]
    #     source_address_prefixes         = ["*"] #var.vnet_address_space
    #     destination_address_prefixes    = ["*"] #var.private_endpoint_subnet_address
    # }

    # Network Security Group Rule for denying public access
    # security_rule {
    #     name                        = "DenyPublicAccess"
    #     priority                    = 300
    #     direction                   = "Inbound"
    #     access                      = "Deny"
    #     protocol                    = "*"
    #     source_port_range           = "*"
    #     destination_port_range      = "*"
    #     source_address_prefix       = "*"
    #     destination_address_prefix  = "*"
    # }
}