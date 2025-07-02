# 🌐 Variables for the VNet Module Demo
# Values should be provided via terraform.tfvars

variable "system_name" {
  description = "The name for the system (used in resource naming)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.system_name))
    error_message = "System name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "The environment name (dev, test, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
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
