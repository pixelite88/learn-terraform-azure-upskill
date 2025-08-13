data "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault" "shared" {
  name                = "sharedcv2307"
  resource_group_name = "shared-cv-scanner"
}