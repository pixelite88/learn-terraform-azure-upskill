# Terraform configuration for Azure Static Web App, Function App and Storage

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "cv_safe" {
  name                  = "cv-safe"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "cv_notsafe" {
  name                  = "cv-notsafe"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "cv_quarantine" {
  name                  = "cv-quarantine"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_service_plan" "plan" {
  name                = "function-app-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_resource_group_template_deployment" "static_web" {
  name                = "static-web-deployment"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    name = {
      value = var.static_web_app_name
    }
    location = {
      value = var.location
    }
    repositoryToken = {
      value = var.github_token
    }
  })

  template_content = jsonencode({
    "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion" = "1.0.0.0",
    "parameters" = {
      "name" = {
        "type" = "string"
      },
      "location" = {
        "type" = "string"
      },
      "repositoryToken" = {
        "type" = "securestring"
      }
    },
    "resources" = [
      {
        "type" = "Microsoft.Web/staticSites",
        "apiVersion" = "2023-01-01",
        "name" = "[parameters('name')]",
        "location" = "[parameters('location')]",
        "properties" = {
          "repositoryUrl" = "https://github.com/pixelite88/azure-fundamentals-upskill",
          "branch" = "main",
          "repositoryToken" = "[parameters('repositoryToken')]",
          "buildProperties" = {
            "appLocation" = "frontend",
            "apiLocation" = "api",
            "outputLocation" = "frontend/build"
          }
        },
        "identity" = {
          "type" = "SystemAssigned"
        },
        "sku" = {
          "name": "Standard",
          "tier": "Standard"
        }
      }
    ]
  })
}  
