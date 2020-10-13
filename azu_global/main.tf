resource "azurerm_resource_group" "resource_group_network_services" {
  name     = "${var.resource_prefix}-NETWORK-SERVICES-rg"
  location = var.resource_location
  tags     = var.resource_tags
}