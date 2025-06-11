variable "vm_name" {
    description = "The name of the virtual machine."
    type        = string
}

variable "location" {
    description = "The Azure region where the virtual machine will be created."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group where the virtual machine will be created."
    type        = string
}

variable "network_interface_id" {
    description = "The ID of the network interface to attach to the virtual machine."
    type        = string
}

variable "vm_size" {
    description = "The size of the virtual machine."
    type        = string
    default     = "Standard_A2_v2"
}

variable "image_publisher" {
    description = "The publisher of the VM image."
    type        = string
    default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
    description = "The offer of the VM image."
    type        = string
    default     = "WindowsServer"
}

variable "image_sku" {
    description = "The SKU of the VM image."
    type        = string
    default     = "2022-datacenter-core"  # Gen 1 compatible with Standard_A2_v2
}

variable "image_version" {
    description = "The version of the VM image."
    type        = string
    default     = "latest"
}

variable "admin_username" {
    description = "The admin username for the virtual machine."
    type        = string
    default     = "adminuser"
}

variable "admin_password" {
    description = "The admin password for the virtual machine."
    type        = string
    sensitive   = true
}

variable "tags" {
    description = "Tags to be applied to the virtual machine."
    type        = map(string)
    default     = {}
}

# Azure Spot VM Configuration for Cost Optimization
variable "priority" {
    description = "The priority of the virtual machine. Use 'Spot' for significant cost savings on testing environments."
    type        = string
    default     = "Regular"
    validation {
        condition     = contains(["Regular", "Spot"], var.priority)
        error_message = "Priority must be either 'Regular' or 'Spot'."
    }
}

variable "eviction_policy" {
    description = "The eviction policy for Spot VMs. Only applies when priority is 'Spot'."
    type        = string
    default     = "Deallocate"
    validation {
        condition     = contains(["Deallocate", "Delete"], var.eviction_policy)
        error_message = "Eviction policy must be either 'Deallocate' or 'Delete'."
    }
}

variable "max_bid_price" {
    description = "The maximum price you're willing to pay for the Spot VM per hour. Set to -1 to pay up to the current on-demand price."
    type        = number
    default     = -1
}