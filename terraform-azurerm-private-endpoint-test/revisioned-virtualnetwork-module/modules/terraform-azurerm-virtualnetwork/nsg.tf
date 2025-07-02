resource "azurerm_network_security_group" "nsg" {
  name                = local.standard_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "rules" {
  for_each                    = var.nsg_rules
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol

  source_port_ranges = length(each.value.source_port_ranges) > 1 ? each.value.source_port_ranges : null
  source_port_range  = length(each.value.source_port_ranges) <= 1 ? each.value.source_port_ranges[0] : null

  destination_port_ranges = length(each.value.destination_port_ranges) > 1 ? each.value.destination_port_ranges : null
  destination_port_range  = length(each.value.destination_port_ranges) <= 1 ? each.value.destination_port_ranges[0] : null

  source_address_prefixes = length(each.value.source_address_prefixes) > 1 ? [for addr in each.value.source_address_prefixes : lookup(var.subnet_configs, addr, addr)] : null
  source_address_prefix   = length(each.value.source_address_prefixes) <= 1 ? lookup(var.subnet_configs, each.value.source_address_prefixes[0], each.value.source_address_prefixes[0]) : null

  destination_address_prefixes = length(each.value.destination_address_prefixes) > 1 ? [for addr in each.value.destination_address_prefixes : lookup(var.subnet_configs, addr, addr)] : null
  destination_address_prefix   = length(each.value.destination_address_prefixes) <= 1 ? lookup(var.subnet_configs, each.value.destination_address_prefixes[0], each.value.destination_address_prefixes[0]) : null
}

resource "azurerm_subnet_network_security_group_association" "associations" {
  for_each                  = var.nsg_attached_subnets
  subnet_id                 = azurerm_subnet.subnet[each.value].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}