resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev"
  location = "Norway East"
}

module "vnet" {
  source = "./modules/terraform-azurerm-virtualnetwork"
  
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
}