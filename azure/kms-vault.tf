data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "garden-enterprise-key-vault" {
  name                        = var.vault_name
  location                    = azurerm_resource_group.garden-enterprise.location
  resource_group_name         = azurerm_resource_group.garden-enterprise.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "garden-enterprise-vault-access" {
  key_vault_id    = azurerm_key_vault.garden-enterprise-key-vault.id
  tenant_id       = data.azurerm_client_config.current.tenant_id
  object_id       = azuread_service_principal.garden-enterprise-vault-principal.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey",
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set",
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update",
  ]
}

resource "azurerm_key_vault_access_policy" "user-vault-access" {
  key_vault_id = azurerm_key_vault.garden-enterprise-key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey",
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set",
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update",
  ]
}

resource "azurerm_key_vault_key" "garden-enterprise-vault-key" {
  name         = "ge-auto-unseal-vault-key"
  key_vault_id = azurerm_key_vault.garden-enterprise-key-vault.id
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
}
