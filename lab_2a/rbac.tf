resource "azurerm_role_assignment" "group_role" {
    scope = data.azurerm_subscription.current.id
    role_definition_name = var.role_name
    principal_id = azuread_group.lab_group.object_id
}