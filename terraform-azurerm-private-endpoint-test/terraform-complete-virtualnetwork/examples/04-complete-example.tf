terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-complete-example"
  location = "norwayeast"
}

resource "azurerm_storage_account" "app_storage" {
  name                          = "stgcompleteexample001"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_key_vault" "app_keyvault" {
  name                          = "kv-complete-example-001"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
}

data "azurerm_client_config" "current" {}

module "hub_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "hub-complete-example"
  system_name         = "hub"
  environment         = "prod"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.0.0.0/16"]
  
  subnet_configs = {
    "shared-services" = "10.0.1.0/24"
    "gateway"         = "10.0.2.0/24"
  }
}

module "complete_spoke_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "spoke-complete-example"
  system_name         = "webapp"
  environment         = "prod"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.1.0.0/16"]
  
  subnet_configs = {
    "web"           = "10.1.1.0/24"
    "app"           = "10.1.2.0/24"
    "data"          = "10.1.3.0/24"
    "private-links" = "10.1.4.0/24"
    "integration"   = "10.1.5.0/24"
  }
  
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_id         = "10.1.4.0/24"
      resource_id       = azurerm_storage_account.app_storage.id
      subresource_names = ["blob"]
    }
    "keyvault" = {
      subnet_id         = "10.1.4.0/24"
      resource_id       = azurerm_key_vault.app_keyvault.id
      subresource_names = ["vault"]
    }
  }
  
  vnet_peering_config = {
    virtual_network_name      = module.hub_vnet.vnet_name
    remote_virtual_network_id = module.hub_vnet.vnet_id
  }
}
