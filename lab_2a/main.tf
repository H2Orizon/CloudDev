terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {}

data "azurerm_management_group" "root" {
  name = "Tenant Root Group"
}

resource "azurerm_management_group" "mg1" {
  display_name              = "az104-mg1"
  name                      = "az104-mg1"
  parent_management_group_id = data.azurerm_management_group.root.id
}

variable "helpdesk_object_id" {
  description = "Object ID групи helpdesk в Entra ID"
  type        = string
}

data "azurerm_management_group" "mg1_ref" {
  name = azurerm_management_group.mg1.name
}

resource "azurerm_role_assignment" "vm_contributor_to_helpdesk" {
  scope                = data.azurerm_management_group.mg1_ref.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = var.helpdesk_object_id
  principal_type       = "Group"
}

resource "azurerm_role_definition" "custom_support_request" {
  name        = "Custom Support Request"
  scope       = data.azurerm_management_group.mg1_ref.id
  description = "A custom contributor role for support requests."

  permissions {
    actions = [
      "Microsoft.Support/*/read",
      "Microsoft.Support/supportServices/*",
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
  scope              = data.azurerm_management_group.mg1_ref.id
  role_definition_id = azurerm_role_definition.custom_support_request.id
  principal_id       = var.helpdesk_object_id
  principal_type     = "Group"
}
