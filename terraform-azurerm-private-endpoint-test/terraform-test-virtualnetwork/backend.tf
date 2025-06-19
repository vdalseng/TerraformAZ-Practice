# terraform {
#   backend "azurerm" {
#     resource_group_name  = "vhd-rg"
#     storage_account_name = "remotestatevhdsa"
#     container_name       = "remotestate-container"
#     key                  = "terraform.tfstate"
#   }
# }
