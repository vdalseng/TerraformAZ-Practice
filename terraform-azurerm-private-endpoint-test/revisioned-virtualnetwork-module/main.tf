resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-${var.system_name}-${var.environment}-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_storage_account" "test" {
  name                     = "sa${var.system_name}${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  public_network_access_enabled = false
}

module "vnet" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = var.system_name
  system_name         = var.system_name
  environment         = var.environment
  resource_group      = azurerm_resource_group.test

  address_space = [var.vnet_address_space]

  subnet_configs = {
    frontend  = cidrsubnet(var.vnet_address_space, 3, 0)
    backend   = cidrsubnet(var.vnet_address_space, 3, 1)
    endpoints = cidrsubnet(var.vnet_address_space, 2, 2)
  }

  nsg_attached_subnets = []
  nsg_rules           = {}

  private_endpoint_configs = {
    storage_blob = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.test.id
      subresource_names = ["blob"]
    }
  }

  vnet_peering_configs = {}
}
