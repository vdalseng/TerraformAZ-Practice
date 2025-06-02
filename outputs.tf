output "subnets" {
    value = azurerm_virtual_network.vetle-vnet.subnet
    description = "Subnets within the virtual network"  
}