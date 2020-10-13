resource "random_string" "string_name" {
  length  = 24
  lower   = true
  upper   = false
  special = false
  number  = false
}

resource "azurerm_storage_account" "storage_account_boot_diag" {
  name                      = random_string.string_name.result
  resource_group_name       = azurerm_resource_group.resource_group_storage_accounts_general.name
  location                  = azurerm_resource_group.resource_group_storage_accounts_general.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = false
  tags                      = var.resource_tags

  network_rules {
    default_action             = "Deny"
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}