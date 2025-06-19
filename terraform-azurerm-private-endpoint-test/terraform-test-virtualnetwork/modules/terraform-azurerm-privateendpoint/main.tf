resource "azurerm_private_endpoint" "private_endpoint" {
    name                = "${var.resource_name}-pe"
    location            = var.resource_group.location
    resource_group_name = var.resource_group.name
    subnet_id           = var.subnet_id

    dynamic "private_service_connection" {
        for_each = var.private_connection_resources
        content {
            name                            = "${var.resource_name}-${private_service_connection.key}-psc"
            private_connection_resource_id  = private_service_connection.value.resource_id
            subresource_names               = private_service_connection.value.subresource_names
            is_manual_connection            = false
        }
    }
}