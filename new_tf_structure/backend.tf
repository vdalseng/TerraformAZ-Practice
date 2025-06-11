terraform {
  backend "azurerm" {
    resource_group_name  = "vhd-rg"
    storage_account_name = "vhdstracc"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
