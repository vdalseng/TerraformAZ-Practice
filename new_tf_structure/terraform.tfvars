# Environment Configuration
environments = ["dev", "test", "prod"]

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
storage_account_name     = "vhdstorageaccount"
account_tier             = "Standard"
account_replication_type = "LRS"

# Key Vault Configuration
key_vault_name        = "vhd-key-vault"
sku_name              = "standard"
#enabled_for_disk_encryption = true
#soft_delete_retention_days = 7
#purge_protection_enabled   = false

# Key Vault Access Policy Configuration
key_permissions       = [ "Get" ]
secret_permissions    = [ "Get", "Set", "List" ]
storage_permissions   = [ "Get" ]

# Key Vault Secret Configuration
key_vault_secret_name = "vhd-storage-account-key"

# Networking Configuration

#Network Security Group Configuration
network_security_group_name = "vhd-net-sec-group"

# Virtual Network Configuration
virtual_network_name = "vhd-vnet"

address_space = ["10.133.99.0/16"]

# Subnet Configuration
subnet_name = "vhd-subnet"
subnet_address_prefix = "10.133.99.0/24"
bastion_subnet_address_prefix = "10.133.99.0/24" # pass this to a subnet module for bastion host

# Service Endpoints Configuration
service_endpoints = ["Microsoft.Storage"]

