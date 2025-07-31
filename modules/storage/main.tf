variable "resource_group_name" {}
variable "location" {}
variable "storage_account_name" {}

# 3. Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name # required
  resource_group_name      = var.resource_group_name  # required
  location                 = var.location  # required
  account_tier             = "Standard"  # required
  account_replication_type = "LRS" # required
}

resource "azurerm_storage_container" "cv" {
  for_each = toset(["cv-safe", "cv-notsafe", "cv-quarantine"])
  name                  = each.value 
  storage_account_id  = azurerm_storage_account.storage.id # required
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "primary_access_key" {
  value = azurerm_storage_account.storage.primary_access_key
  sensitive = true
}