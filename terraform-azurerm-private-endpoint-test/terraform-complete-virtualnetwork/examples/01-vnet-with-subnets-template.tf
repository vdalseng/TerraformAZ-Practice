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
  name     = "rg-vnet-basic-example"
  location = "norwayeast"
}

module "basic_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "webapp-dev-vnet"
  system_name         = "webapp"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.0.0.0/16"]
  
  subnet_configs = {
    "frontend" = "10.0.1.0/24"
    "backend"  = "10.0.2.0/24"
  }
}