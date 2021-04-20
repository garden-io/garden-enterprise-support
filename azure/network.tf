resource "azurerm_virtual_network" "garden-vnet" {
  name                = var.vnet_name
  address_space       = ["10.7.28.0/22"]
  location            = azurerm_resource_group.garden-enterprise.location
  resource_group_name = azurerm_resource_group.garden-enterprise.name
}

resource "azurerm_subnet" "garden-internal" {
  name                 = "garden-enterprise-aks-subnet"
  resource_group_name  = azurerm_resource_group.garden-enterprise.name
  virtual_network_name = azurerm_virtual_network.garden-vnet.name
  address_prefixes     = ["10.7.29.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}
