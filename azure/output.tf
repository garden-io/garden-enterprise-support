output "postgres_server_fqdn" {
    value = azurerm_postgresql_server.garden-postgres.fqdn
}

output "postgres_server_user" {
    value = var.database_admin_login
}

output "postgres_server_password" {
    value = var.database_admin_login_pw
}

output "application_client_id" {
    value = azuread_application.garden-enterprise-app.application_id
}

output "application_client_secret" {
    value = var.app_client_secret
}

output "application_tenant_id" {
    value = data.azurerm_client_config.current.tenant_id
}

output "azure_vault_name" {
    value = azurerm_key_vault.garden-enterprise-key-vault.name
}

output "azure_vault_key_name" {
    value = azurerm_key_vault_key.garden-enterprise-vault-key.name
}
