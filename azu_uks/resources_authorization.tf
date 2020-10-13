data "azurerm_subscription" "subscription" {}

resource "azurerm_role_assignment" "role_assignment_disk_encryption_set" {
  scope                = data.azurerm_subscription.subscription.id
  principal_id         = azurerm_disk_encryption_set.disk_encryption_set.identity[0].principal_id
  role_definition_name = "Reader"
}