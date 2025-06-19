resource_name          = "vhd"
location               = "norwayeast"

tags            = {
  environment   = "dev"
  owner         = "vhd"
  team          = "core"
}

storage_account_names   = [ "primary", "remotestate" ]
address_space           = "10.133.100.0/24"