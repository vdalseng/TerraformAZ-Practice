resource "azurerm_resource_group" "example" {
  name     = "rg-pe-example-dev"
  location = "Norway East"
}

resource "azurerm_storage_account" "example" {
  name                     = "stpeexampledev001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false
  
  tags = {
    environment = "dev"
    purpose     = "private-endpoint-example"
  }
}

module "vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${var.system_name}-basic"
  system_name         = "example"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []
  
  subnet_configs = {
    workloads = cidrsubnet("10.0.0.0/16", 8, 1)
    endpoints = cidrsubnet("10.0.0.0/16", 8, 2)
  }

  nsg_attached_subnets = []
  
  private_endpoint_configs = {
    storage_blob = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
    }
  }
  
  tags = {
    environment = "dev"
    purpose     = "private-endpoint-example"
  }
}