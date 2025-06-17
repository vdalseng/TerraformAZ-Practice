# Environment Configuration
# environments = ["dev", "test", "prod"]

# Basic Infrastructure Configuration
resource_group_name = "vhd-rg"
location            = "norwayeast"

# Tags for resource organization
tags = {
  owner       = "vetlehd"
  project     = "vhd-terraform"
  environment = "multi"
}

# Storage Account Configuration
storage_account_name     = "vhdstracc"
account_tier             = "Standard"
account_replication_type = "LRS"

# Key Vault Configuration
# key_vault_name        = "vhd-key-vault"
# sku_name              = "standard"
#enabled_for_disk_encryption = true
#soft_delete_retention_days = 7
#purge_protection_enabled   = false

# Key Vault Access Policy Configuration
# key_permissions       = [ "Get" ]
# secret_permissions    = [ "Get", "Set", "List" ]
# storage_permissions   = [ "Get" ]

# Key Vault Secret Configuration
# key_vault_secret_name = "vhd-storage-account-key"

# Networking Configuration

#Network Security Group Configuration
# network_security_group_name = "vhd-net-sec-group"

# Virtual Network Configuration
virtual_network_name = "vhd-vnet"

address_space = ["10.133.99.0/24"]

# Subnet Configuration
subnet_name = "vhd-subnet"
subnet_address_prefix = "10.133.99.0/25"
bastion_subnet_address_prefix = "10.133.99.128/25"

# Service Endpoints Configuration
# service_endpoints = ["Microsoft.Storage"]

# DNS Zone Configuration
service_type = "blob"
azure_environment = "core.windows.net"

# Private Endpoint Configuration
private_endpoint_name = "vhd-storage-private-endpoint"
private_service_connection_name = "vhd-storage-connection"
subresource_names = ["blob"]
# dns_zone_group_name = "storage-account"

# Network Interface Configuration
network_interface_name = "vhd-vm-nic"
private_ip_address_allocation = "Dynamic"
# private_ip_address = null  # Only set if using Static allocation
# public_ip_address_id = null  # Set if you want to attach a public IP

# Virtual Machine Configuration
vm_name = "vhd-vm"
vm_size = "Standard_A2_v2"
admin_username = "Azureadmin"
admin_password = "Azureadmin!"  # Change this in production

# Azure Spot VM Configuration for Maximum Cost Savings (Testing Only)
# WARNING: Spot VMs can be evicted with 30 seconds notice when Azure needs capacity
priority = "Spot"          # Enable Spot VM for up to 90% cost savings
eviction_policy = "Deallocate"  # Deallocate (preserves data) vs Delete
max_bid_price = -1         # Pay current spot price (up to regular price)