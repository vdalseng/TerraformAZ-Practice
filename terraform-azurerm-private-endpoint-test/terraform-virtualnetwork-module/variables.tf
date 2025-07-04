# 🌐 Variables for the VNet Module Demo
# Values should be provided via terraform.tfvars

variable "system_name" {
  description = "The name for the system (used in resource naming)"
  type        = string
}

variable "environment" {
  description = "The environment name (dev, test, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vnet_a_address_space" {
  description = "CIDR block for VNet A (should be /23 or larger for subnet splitting)"
  type        = string
}
