resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS" 
  min_tls_version          = "TLS1_2"

  allow_blob_public_access  = false 
  network_rules {
    default_action = "Deny" 
  }

  # Допоміжні налаштування:
  enable_https_traffic_only = true
  tags = {
    environment = "lab07"
  }
}

resource "azurerm_storage_container" "blob_data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private" 
}

resource "azurerm_storage_share" "file_share1" {
  name                 = "share1"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 100
}
