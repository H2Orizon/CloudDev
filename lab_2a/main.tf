terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.34.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {}

resource "azurerm_management_group" "mg1" {
  name         = "az104-mg1"
  display_name = "az104-mg1"
}

data "azurerm_management_group" "mg1_ref" {
  name = azurerm_management_group.mg1.name
}

resource "azuread_group" "helpdesk" {
  display_name     = "helpdesk"
  security_enabled = true
  visibility       = "Public"
}

resource "time_sleep" "wait_for_ad" {
  depends_on = [azuread_group.helpdesk]
  create_duration = "30s"
}

resource "azurerm_role_assignment" "vm_contributor_to_helpdesk" {
  depends_on = [time_sleep.wait_for_ad]
  scope                = data.azurerm_management_group.mg1_ref.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_group.helpdesk.object_id
  principal_type       = "Group"
}

resource "azurerm_role_definition" "custom_support_request" {
  name        = "CustomSupportRequest"
  scope       = data.azurerm_management_group.mg1_ref.id
  description = "Custom role for support-related operations."

  permissions {
    actions = [
      "Microsoft.Support/*/read",
      "Microsoft.Compute/virtualMachines/*"
    ]

    not_actions = [
      "Microsoft.Support/register/action"
    ]
  }

  assignable_scopes = [
    data.azurerm_management_group.mg1_ref.id
  ]
}

resource "azurerm_role_assignment" "custom_support_request_to_helpdesk" {
  depends_on = [
    time_sleep.wait_for_ad,
    azurerm_role_definition.custom_support_request
  ]

  scope              = data.azurerm_management_group.mg1_ref.id
  role_definition_id = azurerm_role_definition.custom_support_request.role_definition_resource_id
  principal_id       = azuread_group.helpdesk.object_id
  principal_type     = "Group"
}
