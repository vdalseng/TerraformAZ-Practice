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
  name     = "rg-vnet-privateendpoint-example"
  location = "norwayeast"
}

resource "azurerm_storage_account" "example" {
  name                          = "stgprivateendpointex001"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

module "vnet_with_pe" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "pe-example-vnet"
  system_name         = "storage"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.1.0.0/16"]
  
  subnet_configs = {
    "app"           = "10.1.1.0/24"
    "private-links" = "10.1.2.0/24"
  }
  
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_id         = "10.1.2.0/24"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
    }
  }
}