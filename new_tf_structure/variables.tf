variable "resource_group_name" {
    description = "The name of the resource group."
    type        = string
}

variable "location" {
    description = "The region to create the resource"
    type        = string
}

variable "storage_account_name" {
    description = "The name of the storage account."
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to the storage account."
    type        = map(string)
    default     = {}
}

variable "account_tier" {
    description = "The tier of the storage account."
    type        = string
    default     = "Standard"
}

variable "account_replication_type" {
    description = "The replication type of the storage account."
    type        = string
    default     = "LRS"
}

variable "key_vault_name" {
    description = "The name of the Key Vault."
    type        = string
}

variable "sku_name" {
    description = "The SKU name for the Key Vault."
    type        = string
    default     = "standard"
}

variable "enabled_for_disk_encryption" {
    description = "Whether the Key Vault is enabled for disk encryption."
    type        = bool
    default     = true
}

variable "soft_delete_retention_days" {
    description = "The number of days to retain soft-deleted Key Vaults."
    type        = number
    default     = 7
}

variable "purge_protection_enabled" {
    description = "Whether purge protection is enabled for the Key Vault."
    type        = bool
    default     = false
}

variable "environments" {
    description = "A list of environments for which the Key Vault should be created."
    type        = list(string)
}

variable "key_permissions" {
    description = "The permissions for keys in the Key Vault."
    type        = list(string)
}

variable "secret_permissions" {
    description = "The permissions for secrets in the Key Vault."
    type        = list(string)
}

variable "storage_permissions" {
    description = "The permissions for storage in the Key Vault."
    type        = list(string)
}

variable "key_vault_secret_name" {
    description = "The name of the Key Vault secret."
    type        = string
}

variable "network_security_group_name" {
    description = "The name of the Network Security Group."
    type        = string
}

variable "virtual_network_name" {
    description = "The name of the Virtual Network."
    type        = string
}

variable "address_space" {
    description = "The address space for the Virtual Network in CIDR notation."
    type        = list(string)
}

variable "dns_servers" {
    description = "A list of DNS server IP addresses for the Virtual Network."
    type        = list(string)
    default     = []
}

variable "subnet_name" {
    description = "The name of the subnet."
    type        = string
}

variable "subnet_address_prefix" {
    description = "The address prefix for the subnet in CIDR notation."
    type        = string
}

variable "bastion_subnet_address_prefix" {
    description = "The address prefix for the bastion subnet in CIDR notation."
    type        = string
}

variable "service_endpoints" {
    description = "A list of service endpoints to enable for the subnet."
    type        = list(string)
    default     = []
}

variable "service_type" {
    description = "The Azure Service type for the private DNS zone"
    type        = string
}

variable "azure_environment" {
    description = "Azure environment (core.windows.net, etc.)"
    type        = string
}

# Private Endpoint Configuration
variable "private_endpoint_name" {
    description = "The name of the private endpoint."
    type        = string
}

variable "private_service_connection_name" {
    description = "The name of the private service connection."
    type        = string
}

variable "subresource_names" {
    description = "The names of the subresources for the private service connection (e.g., 'blob' for storage accounts)."
    type        = list(string)
    default     = ["blob"]
}

variable "dns_zone_group_name" {
    description = "The name of the DNS zone group for the private endpoint."
    type        = string
    default     = "storage-account"
}

# Network Interface Configuration
variable "network_interface_name" {
    description = "The name of the network interface."
    type        = string
}

variable "private_ip_address_allocation" {
    description = "The allocation method for the private IP address (Dynamic or Static)."
    type        = string
    default     = "Dynamic"
}

variable "private_ip_address" {
    description = "The static private IP address to assign (only used if allocation is Static)."
    type        = string
    default     = null
}

variable "public_ip_address_id" {
    description = "The ID of the public IP address to associate with the network interface."
    type        = string
    default     = null
}

# Virtual Machine Configuration
variable "vm_name" {
    description = "The name of the virtual machine."
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
    default     = "2022-datacenter-smalldisk"  # Gen 1 compatible with Standard_A2_v2
}

variable "image_version" {
    description = "The version of the VM image."
    type        = string
    default     = "latest"
}

variable "admin_username" {
    description = "The admin username for the virtual machine."
    type        = string
    default     = "azureadmin"
}

variable "admin_password" {
    description = "The admin password for the virtual machine."
    type        = string
    sensitive   = true
}

# Azure Spot VM Configuration for Cost Optimization
variable "priority" {
    description = "The priority of the virtual machine. Use 'Spot' for significant cost savings on testing environments."
    type        = string
    default     = "Regular"
}

variable "eviction_policy" {
    description = "The eviction policy for Spot VMs. Only applies when priority is 'Spot'."
    type        = string
    default     = "Deallocate"
}

variable "max_bid_price" {
    description = "The maximum price you're willing to pay for the Spot VM per hour. Set to -1 to pay up to the current on-demand price."
    type        = number
    default     = -1
}