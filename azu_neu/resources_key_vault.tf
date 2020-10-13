data "azurerm_client_config" "current" {}

#########################################################################################################
##### Kay Vaults
#########################################################################################################

resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.resource_prefix}-kv"
  location                    = azurerm_resource_group.resource_group_key_vaults.location
  resource_group_name         = azurerm_resource_group.resource_group_key_vaults.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  soft_delete_enabled         = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  tags                        = var.resource_tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.trusted_ip_addresses
  }

}

#########################################################################################################
##### Disk Encryption Sets
#########################################################################################################

resource "azurerm_disk_encryption_set" "disk_encryption_set" {
  name                = "AzureManagedDisksEncryption"
  resource_group_name = azurerm_resource_group.resource_group_key_vaults.name
  location            = azurerm_resource_group.resource_group_key_vaults.location
  key_vault_key_id    = azurerm_key_vault_key.key_vault_key_encrypted_disks.id

  identity {
    type = "SystemAssigned"
  }
}

#########################################################################################################
##### Key Vault Access Policies
#########################################################################################################

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_encrypted_disks" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_disk_encryption_set.disk_encryption_set.identity.0.principal_id

  key_permissions = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "wrapKey",
    "verify",
    "get",
  ]
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_terraform_application" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "create",
    "delete",
    "recover",
  ]
}

#########################################################################################################
##### Key Vault Keys
#########################################################################################################

resource "azurerm_key_vault_key" "key_vault_key_encrypted_disks" {
  name         = "AzureManagedDisksEncryption"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_access_policy_terraform_application,
  ]
}