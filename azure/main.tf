terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.55.0"
    }    
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "azuread" {
}

resource "azurerm_resource_group" "garden-enterprise" {
  name     = var.resource_group
  location = var.resource_group_location
}
