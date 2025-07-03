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

variable "vnet_address_space" {
  description = "CIDR block for the virtual network (should be /23 or larger for subnet splitting)"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "VNet address space must be a valid CIDR block."
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan for the VNet"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID of existing DDoS protection plan (required if enable_ddos_protection is true)"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
