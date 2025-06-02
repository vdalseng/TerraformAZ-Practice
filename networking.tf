// AzureRM Networking

// NSG can be configured to control inbound and outbound traffic for specified subnets
resource "azurerm_network_security_group" "network-security-group" {
    name                = "NetSecurityGroup"
    location            = azurerm_resource_group.vetle-rg.location
    resource_group_name = azurerm_resource_group.vetle-rg.name
    
    // Security rules define the access control for the NSG
    security_rule {
        name                       = "test123"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "shared"
    }
}

// Virtual Network is a representation of your own network in Azure
// It can be used to connect different resources like VMs, databases, etc.
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    location            = azurerm_resource_group.vetle-rg.location
    resource_group_name = azurerm_resource_group.vetle-rg.name
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.0.4", "10.0.0.5"]

    // Subnets are segments of the virtual network that can be used to isolate resources
    subnet {
        name             = "subnet1"
        address_prefixes = ["10.0.1.0/24"]
    }

    subnet {
        name             = "subnet2"
        address_prefixes = ["10.0.2.0/24"]
        security_group   = azurerm_network_security_group.network-security-group.id
    }

    tags = {
        environment = "shared"
    }
}

resource "azurerm_network_interface" "network-interface" {
    name                = "nic"
    location            = azurerm_resource_group.vetle-rg.location
    resource_group_name = azurerm_resource_group.vetle-rg.name

    ip_configuration {
        name                            = "internal"
        subnet_id                       = azurerm_virtual_network.vnet.subnet.*.id
        private_ip_address_allocation   = "Dynamic"
    }

    tags = {
        environment = "shared"
    }
}

// Enables centralized management of VNets
resource "azurerm_virtual_wan" "virtual-wan" {
    name                = "vwan"
    resource_group_name = azurerm_resource_group.vetle-rg.name
    location            = azurerm_resource_group.vetle-rg.location
}

// Acts as a central point for routing traffic between VNets and on-premises networks
resource "azurerm_virtual_hub" "vetle-vhub" {
    name                = "vetlevhub"
    resource_group_name = azurerm_resource_group.vetle-rg.name
    location            = azurerm_resource_group.vetle-rg.location
    virtual_wan_id      = azurerm_virtual_wan.vetle-vwan.id
    address_prefix      = "10.0.3.0/24"

    sku = "Basic"
}

// Provides a secure connection for remote users or on-premises networks to resources in the VNet
resource "azurerm_vpn_gateway" "vetle-vpn-gw" {
    name                = "vetlevpngw"
    location            = azurerm_resource_group.vetle-rg.location
    resource_group_name = azurerm_resource_group.vetle-rg.name
    virtual_hub_id      = azurerm_virtual_hub.vetle-vhub.id
}


# resource "azurerm_windows_virtual_machine" "vetle-vm" {
#   name                = "vetlevm"
#   resource_group_name = azurerm_resource_group.vetle-rg.name
#   location            = azurerm_resource_group.vetle-rg.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password      = "P@$$w0rd1234!"
#   network_interface_ids = [
#     azurerm_network_interface.example.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }
# }