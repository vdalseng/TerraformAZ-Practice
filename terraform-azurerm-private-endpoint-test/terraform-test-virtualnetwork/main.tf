resource "azurerm_resource_group" "resource_group" {
    name        = "${var.resource_name}-rg"
    location    = var.location
    tags        = var.tags
}

// Create two storage accounts: one for remote state (public access) and another for testing private endpoints (restricted access)

resource "azurerm_storage_account" "storage_account" {
    for_each                 = toset(var.storage_account_names)
    name                     = "${each.value}${var.resource_name}sa"
    resource_group_name      = azurerm_resource_group.resource_group.name
    location                 = azurerm_resource_group.resource_group.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    public_network_access_enabled = each.value == "remotestate" ? true : false
    
    dynamic "network_rules" {
        for_each = each.value == "remotestate" ? [] : [1]
        content {
            default_action = "Deny"
            bypass         = ["AzureServices", "Logging", "Metrics"]

            ip_rules = []
            virtual_network_subnet_ids = []
        }
    }
}

// Create two storage containers: one for remote state storage and another for testing private endpoints access
resource "azurerm_storage_container" "container" {
    for_each             = toset(var.storage_account_names)
    name                 = "${each.value}-container"
    storage_account_id   = azurerm_storage_account.storage_account[each.value].id
    container_access_type = "private"
}

module "virtualnetwork" {
  source = "./modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = var.resource_name
  environment         = var.environment
  resource_group      = azurerm_resource_group.resource_group
  subnet_configs      = {
    "AzureBastionSubnet" = cidrsubnet(var.address_space, 1, 0)
    "internal" = cidrsubnet(var.address_space, 1, 1)
  }

  nsg_attached_subnets = []

  system_name       = var.resource_name
  address_space     = [var.address_space]
}


# Public IP for Bastion Host
resource "azurerm_public_ip" "pip" {
    name                    = "${var.resource_name}-pip"
    location                = var.location
    resource_group_name     = azurerm_resource_group.resource_group.name
    allocation_method       = "Static"
    sku                     = "Standard"
}

# Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "${var.resource_name}-bastion"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  #dns_name            = "${var.resource_name}-bastion"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.virtualnetwork.azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "nic" {
    name                = "${var.resource_name}-nic"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name

    ip_configuration {
        name                          = "${var.resource_name}-ipconfig"
        subnet_id                     = module.virtualnetwork.azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_windows_virtual_machine" "vm" {
    name                = "${var.resource_name}-vm"
    location            = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    size                = "Standard_A2_v2"
    admin_username      = "Adminuser"
    admin_password      = "Adminuser!"
    network_interface_ids = [azurerm_network_interface.nic.id]

    # Azure Spot VM configuration for maximum cost savings (testing environments)
    priority        = "Spot"
    eviction_policy = "Deallocate"
    max_bid_price   = -1

    # Windows-specific configuration
    provision_vm_agent         = true

    # OS disk configuration - cheapest options
    os_disk {
        name                 = "${var.resource_name}-osdisk"
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


module "private_endpoint" {
    source = "./modules/terraform-azurerm-privateendpoint"

    resource_group = azurerm_resource_group.resource_group
    resource_name  = var.resource_name
    subnet_id    = module.virtualnetwork.azurerm_subnet.internal.id

    private_connection_resources = {
        "primary-storage" = {
            resource_id       = azurerm_storage_account.storage_account["primary"].id
            subresource_names = ["blob"]
        },
        "remotestate-storage" = {
            resource_id       = azurerm_storage_account.storage_account["remotestate"].id
            subresource_names = ["blob"]
        }
    }
}