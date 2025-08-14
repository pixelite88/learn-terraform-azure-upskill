terraform {
  backend "azurerm" {
    resource_group_name  = "upskill-tfstate-rg"
    storage_account_name = "upskilltfstate"
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
  }
}