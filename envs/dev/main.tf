terraform {
  backend "azurerm" {
    resource_group_name  = "cv-terraform-state-dev"
    storage_account_name = "cvtfstatedev" // zmień na unikalną nazwę
    container_name      = "terraform-state"
    key                 = "dev.tfstate"
  }
}

provider "azurerm" {
  features {
      key_vault {
        purge_soft_delete_on_destroy    = true
        recover_soft_deleted_key_vaults = true
      }
  }
  subscription_id = "7ab5a8c1-fa92-4df5-bb84-3c45fd83a4c5"
  # skip_provider_registration = true
}

locals {
  env = "dev"
  location = "westeurope"
}

module "infrastructure" {
  source              = "../../modules/infrastructure"
  location            = local.location
  env                 = local.env
  resource_group_name   = "cvresourcegroup-${local.env}"
  function_app_name     = "cvscannerfunc-${local.env}"
  static_web_app_name   = "cvstaticweb-${local.env}"
  storage_account_name  = "cvstorageacct${local.env}"
}

