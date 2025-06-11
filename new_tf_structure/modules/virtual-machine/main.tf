resource "azurerm_windows_virtual_machine" "vm" {
    name                = var.vm_name
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = var.vm_size
    admin_username      = var.admin_username
    admin_password      = var.admin_password    # Network configuration
    network_interface_ids = [var.network_interface_id]

    # Azure Spot VM configuration for maximum cost savings (testing environments)
    priority        = var.priority
    eviction_policy = var.eviction_policy
    max_bid_price   = var.max_bid_price

    # Windows-specific configuration
    provision_vm_agent         = true

    # Boot diagnostics disabled to save storage costs
    boot_diagnostics {}

    # OS disk configuration - cheapest options
    os_disk {
        name                 = "${var.vm_name}-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    # Source image configuration
    source_image_reference {
        publisher = var.image_publisher
        offer     = var.image_offer
        sku       = var.image_sku
        version   = var.image_version
    }

    tags = var.tags
}