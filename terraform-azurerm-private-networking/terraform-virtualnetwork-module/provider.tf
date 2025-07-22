terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  #   client_id       = var.client_id
  #   client_secret   = var.client_secret
  #   tenant_id       = var.tenant_id
  features {}
}

data "azurerm_client_config" "current" {}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}