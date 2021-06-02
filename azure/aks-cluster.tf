resource "azurerm_kubernetes_cluster" "garden-enterprise" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.garden-enterprise.location
  resource_group_name = azurerm_resource_group.garden-enterprise.name
  dns_prefix          = "garden-enterprise"

  default_node_pool {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.garden-internal.id
  }

  network_profile {

    network_plugin = "azure"
    service_cidr = "172.100.0.0/24"
    dns_service_ip = "172.100.0.10"
    docker_bridge_cidr = "172.101.0.1/16"
    load_balancer_sku = "standard"

  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = false
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "garden-enterprise"
  }
}
