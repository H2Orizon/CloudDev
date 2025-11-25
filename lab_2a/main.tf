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

data "azuread_domains" "verified" {
  only_initial = true
}


resource "azurerm_management_group" "mg1" {
  name         = "az104-02-mg1"
  display_name = "az104-02-mg1"
}

resource "azurerm_management_group_subscription_association" "mg1_sub" {
  management_group_id = azurerm_management_group.mg1.id
  subscription_id     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}

resource "azuread_user" "labuser" {
  user_principal_name = "az104-02-aaduser1@${data.azuread_domains.verified.domains[0].domain_name}"
  display_name        = "az104-02-aaduser1"
  password            = "P@ssw0rd1234!"
  force_password_change = false
}

resource "azuread_group" "helpdesk" {
  display_name     = "helpdesk"
  security_enabled = true
  visibility       = "Public"
}

resource "azuread_group_member" "add_labuser" {
  group_object_id  = azuread_group.helpdesk.id
  member_object_id = azuread_user.labuser.id
}

resource "time_sleep" "wait_for_ad" {
  depends_on      = [azuread_group.helpdesk]
  create_duration = "30s"
}

resource "azurerm_role_assignment" "vm_contributor_to_helpdesk" {
  depends_on           = [time_sleep.wait_for_ad]
  scope                = azurerm_management_group.mg1.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_group.helpdesk.object_id
  principal_type       = "Group"
}

resource "azurerm_role_definition" "custom_support_request" {
  name        = "CustomSupportRequest"
  scope       = azurerm_management_group.mg1.id
  description = "Custom role for support-related operations."

  permissions {
    actions = [
      "Microsoft.Support/*",
      "Microsoft.Compute/virtualMachines/*"
    ]
    not_actions = [
      "Microsoft.Support/register/action"
    ]
  }

  assignable_scopes = [
    azurerm_management_group.mg1.id
  ]
}

resource "azurerm_role_assignment" "custom_support_request_to_helpdesk" {
  depends_on = [
    time_sleep.wait_for_ad,
    azurerm_role_definition.custom_support_request
  ]
  scope              = azurerm_management_group.mg1.id
  role_definition_id = azurerm_role_definition.custom_support_request.role_definition_resource_id
  principal_id       = azuread_group.helpdesk.object_id
  principal_type     = "Group"
}
