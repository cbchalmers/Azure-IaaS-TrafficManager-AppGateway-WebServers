resource "azurerm_resource_group" "resource_group_key_vaults" {
  name     = "${var.resource_prefix}-KEY-VAULTS-rg"
  location = var.resource_location
  tags     = var.resource_tags
}

resource "azurerm_resource_group" "resource_group_network_services" {
  name     = "${var.resource_prefix}-NETWORK-SERVICES-rg"
  location = var.resource_location
  tags     = var.resource_tags
}

resource "azurerm_resource_group" "resource_group_storage_accounts_general" {
  name     = "${var.resource_prefix}-STORAGE-ACCOUNTS-GENERAL-rg"
  location = var.resource_location
  tags     = var.resource_tags
}

resource "azurerm_resource_group" "resource_group_web_front_tier_services" {
  name     = "${var.resource_prefix}-WEB-FRONT-TIER-SERVICES-rg"
  location = var.resource_location
  tags     = var.resource_tags
}