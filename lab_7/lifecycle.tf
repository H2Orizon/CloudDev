для продакшину

resource "azurerm_storage_management_policy" "policy" {
  storage_account_id = azurerm_storage_account.sa.id

  rule {
    name    = "MoveToCool"
    enabled = true

    filters {
      blob_types         = ["blockBlob"]
      prefix_match       = ["securitytest/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}
