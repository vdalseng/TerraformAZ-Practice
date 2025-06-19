locals {
  standard_name = "${var.system_name}-${var.environment}"
  vnet          = concat(azurerm_virtual_network.vnet.*, [null])[0]
  subnet        = concat(azurerm_subnet.subnet.*, [null])
  subnet_count  = length(azurerm_subnet.subnet)
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.name_override != "" ? var.name_override : local.standard_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []
    content {
      id = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each                          = var.subnet_configs
  name                              = each.key
  resource_group_name               = var.resource_group.name
  address_prefixes                  = [each.value]
  virtual_network_name              = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies = var.private_endpoint_network_policies
}