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
  name     = "rg-vnet-peering-example"
  location = "norwayeast"
}

module "hub_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "hub-vnet"
  system_name         = "hub"
  environment         = "prod"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.0.0.0/16"]
  
  subnet_configs = {
    "gateway"     = "10.0.1.0/24"
    "firewall"    = "10.0.2.0/24"
    "shared-svcs" = "10.0.3.0/24"
  }
}

module "spoke_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "spoke1-vnet"
  system_name         = "spoke1"
  environment         = "prod"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.1.0.0/16"]
  
  subnet_configs = {
    "web"  = "10.1.1.0/24"
    "app"  = "10.1.2.0/24"
    "data" = "10.1.3.0/24"
  }
  
  vnet_peering_config = {
    virtual_network_name      = module.hub_vnet.vnet_name
    remote_virtual_network_id = module.hub_vnet.vnet_id
  }
}
