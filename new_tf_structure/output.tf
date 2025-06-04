output "resource_group" {
    description     = "The resource group details."
    value           = {
        id              = module.resource-group.id
        name            = module.resource-group.resource_group_name
        location        = module.resource-group.location
    }
}

output "storage_account" {
    description     = "Storage account details"
    value           = {
        id                      = module.storage-account.storage_account_id
        name                    = module.storage-account.storage_account_name
        primary_blob_endpoint   = module.storage-account.primary_blob_endpoint
    }
}