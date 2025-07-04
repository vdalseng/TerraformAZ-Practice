resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${var.system_name}-network-${var.environment}-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "sa${var.system_name}${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  public_network_access_enabled = false
}

module "vnet_a" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${var.system_name}-net-a"
  system_name         = var.system_name
  environment         = var.environment
  resource_group      = azurerm_resource_group.network

  address_space = [var.vnet_a_address_space]

  subnet_configs = {
    workloads = cidrsubnet(var.vnet_a_address_space, 2, 0)
    endpoints = cidrsubnet(var.vnet_a_address_space, 2, 1)
  }

  nsg_attached_subnets = []
  nsg_rules = {}

  # Create DNS zones and auto-discover from azure_private_link_zones.tf
  create_dns_zones = true

  private_endpoint_configs = {
    storage_blob = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
    }
  }
}
