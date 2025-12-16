output "subscription_id" {
    description = "Current Azure subscription ID"
    value = data.azurerm_subscription.current.subscription_id
}


output "subscription_scope" {
    description = "Subscription scope"
    value = data.azurerm_subscription.current.id
}


output "entra_group_name" {
    description = "Name of the created Entra ID group"
    value = azuread_group.lab_group.display_name
}


output "entra_group_object_id" {
    description = "Object ID of the Entra ID group"
    value = azuread_group.lab_group.object_id
}


output "role_assignment_id" {
    description = "RBAC role assignment ID"
    value = azurerm_role_assignment.group_role.id
}