resource "azurerm_resource_group" "resource_group" {
    // In most resources, the name and location are required
    name     = var.resource_group_name
    location = var.location

    tags = var.tags
}