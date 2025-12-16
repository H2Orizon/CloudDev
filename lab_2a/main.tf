
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "azuread_group" "lab_group" {
    display_name = var.entra_group_name
    security_enabled = true
}