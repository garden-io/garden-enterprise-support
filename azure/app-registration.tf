resource "azuread_application" "garden-enterprise-app" {
  display_name               = "garden-enterprise-app"
  available_to_other_tenants = false
  oauth2_permissions         = []
  oauth2_allow_implicit_flow = true

  required_resource_access {
    // id of Azure Key Vault
    resource_app_id = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"

    resource_access {
      // id for user_impersonation
      id   = "f53da476-18e3-4152-8e01-aec403e6edc0"
      type = "Scope"
    }
  }

  required_resource_access {
    // id of Graph
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      // id for User.Read 
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "garden-enterprise-vault-principal" {
  application_id               = azuread_application.garden-enterprise-app.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "garden-enterprise-vault_pwd" {
  application_object_id = azuread_application.garden-enterprise-app.id
  description           = "client secret for AKS"
  value                 = var.app_client_secret
  end_date              = "2099-01-01T01:02:03Z"
}
