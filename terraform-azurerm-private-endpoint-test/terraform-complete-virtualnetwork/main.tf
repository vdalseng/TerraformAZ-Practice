resource "azurerm_resource_group" "example" {
  name     = var.rg-name
  location = var.location
}

# Second resource group in West Europe for testing peering
resource "azurerm_resource_group" "resource_group_west_europe" {
  name     = "${var.rg-name}-westeurope"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage_1" {
  name                     = "stgaccexample001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = ["188.95.241.183"]
    virtual_network_subnet_ids = []
  }

  shared_access_key_enabled = true

  https_traffic_only_enabled = true
}

resource "azurerm_storage_container" "storage_1_container" {
  name                  = "data-container"
  storage_account_id    = azurerm_storage_account.storage_1.id
  container_access_type = "private"
}

resource "azurerm_storage_account" "storage_2" {
  name                          = "stgaccexample002"
  resource_group_name           = azurerm_resource_group.resource_group_west_europe.name
  location                      = azurerm_resource_group.resource_group_west_europe.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = ["188.95.241.183"] # Your IP for Terraform deployment
    virtual_network_subnet_ids = []                 # Using private endpoints instead
  }
}

resource "azurerm_storage_container" "storage_2_container" {
  name                  = "cross-region-container"
  storage_account_id    = azurerm_storage_account.storage_2.id
  container_access_type = "private"
}

locals {
  vnet1_cidr = "10.133.100.0/23"
  vnet2_cidr = "10.133.102.0/23"
}

module "vnet1" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${var.vnet_canonical_name}-1"
  system_name         = "${var.system_name}-1"
  environment         = var.environment
  resource_group      = azurerm_resource_group.example
  address_space       = [local.vnet1_cidr]

  subnet_configs = {
    "AzureBastionSubnet" = cidrsubnet(local.vnet1_cidr, 1, 0)
    "backend"            = cidrsubnet(local.vnet1_cidr, 1, 1)
  }

  nsg_attached_subnets = []
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_name       = "backend"
      resource_id       = azurerm_storage_account.storage_1.id
      subresource_names = ["blob"]
    }
  }

  # VNet peering to vnet2 in West Europe (DNS forwarding disabled for initial deployment)
  vnet_peering_configs = {
    "to-vnet2" = {
      remote_vnet_name = "${var.system_name}-2-${var.environment}"
      remote_rg_name   = azurerm_resource_group.resource_group_west_europe.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = false # Disabled for initial deployment
        import_remote_zones = false
        export_local_zones  = false
      }
    }
  }
}

module "vnet2" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${var.vnet_canonical_name}-2"
  system_name         = "${var.system_name}-2"
  environment         = var.environment
  resource_group      = azurerm_resource_group.resource_group_west_europe
  address_space       = [local.vnet2_cidr]

  subnet_configs = {
    "web-app" = cidrsubnet(local.vnet2_cidr, 1, 0)
    "app-api" = cidrsubnet(local.vnet2_cidr, 1, 1)
  }

  nsg_attached_subnets = []
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_name       = "web-app"
      resource_id       = azurerm_storage_account.storage_2.id
      subresource_names = ["blob"]
    }
  }

  # VNet peering back to vnet1 in Norway East (DNS forwarding disabled for initial deployment)
  vnet_peering_configs = {
    "to-vnet1" = {
      remote_vnet_name = "${var.system_name}-1-${var.environment}"
      remote_rg_name   = azurerm_resource_group.example.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = false # Disabled for initial deployment
        import_remote_zones = false
        export_local_zones  = false
      }
    }
  }
}








# VM, Network Interface, and Public IP
resource "azurerm_public_ip" "pip" {
  name                = "${azurerm_resource_group.example.name}-pip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "${azurerm_resource_group.example.name}-bastion"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.vnet1.azurerm_subnet["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${azurerm_resource_group.example.name}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "${azurerm_resource_group.example.name}-ipconfig"
    subnet_id                     = module.vnet1.azurerm_subnet["backend"].id
    private_ip_address_allocation = "Dynamic"
  }
}

#Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.system_name}-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  size                  = "Standard_A2_v2"
  admin_username        = "Adminuser"
  admin_password        = "Adminuser!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Azure Spot VM configuration for maximum cost savings (testing environments)
  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1

  # Windows-specific configuration
  provision_vm_agent = true # OS disk configuration - cheapest options
  os_disk {
    name                 = "${azurerm_resource_group.example.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Source image configuration
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk"
    version   = "Latest"
  }
}