resource "azurerm_postgresql_server" "garden-postgres" {
  name                = var.database_server_name
  location            = azurerm_resource_group.garden-enterprise.location
  resource_group_name = azurerm_resource_group.garden-enterprise.name

  sku_name = "GP_Gen5_2"
  version  = "11"

  storage_mb                    = 40960
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false

  administrator_login          = var.database_admin_login
  administrator_login_password = var.database_admin_login_pw

  ssl_enforcement_enabled       = true
}

resource "azurerm_postgresql_database" "garden-postgres" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.garden-enterprise.name
  server_name         = azurerm_postgresql_server.garden-postgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_virtual_network_rule" "postgres-aks-vnet-rule" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.garden-enterprise.name
  server_name                          = azurerm_postgresql_server.garden-postgres.name
  subnet_id                            = azurerm_subnet.garden-internal.id
  ignore_missing_vnet_service_endpoint = true
}
