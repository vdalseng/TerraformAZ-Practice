locals {
    private_endpoint_name = "pe-${var.resource_name}-${var.subresource_name}"
}

resource "azurerm_private_endpoint" "private_endpoint" {
    name                        = local.private_endpoint_name
    resource_group_name         = var.resource_group_name
    location                    = var.resource_group_location
    subnet_id                   = var.private_endpoint_subnet_id

    private_service_connection {
        name                            =  var.resource_name
        is_manual_connection            = false
        private_connection_resource_id  = var.resource_id
        subresource_names               = [var.subresource_name]
    }

    dynamic "private_dns_zone_group" {
        for_each = var.private_dns_zone_id != null ? [1] : []
        content {
            name                 = "${var.resource_name}-${var.subresource_name}-dns-zone-group"
            private_dns_zone_ids = [var.private_dns_zone_id]
        }
    }   

    tags = merge(
        var.tags,
        {
            ResourceName            = "${local.private_endpoint_name}-connection"
            Description             = "Private Endpoint for ${var.resource_name}-${var.subresource_name}"
            TerraformReference      = "azurerm_private_endpoint.private_endpoint"
        }
    )
}