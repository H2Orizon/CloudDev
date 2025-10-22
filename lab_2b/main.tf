terraform {
  required_providers{
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.100.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm"{
    features {}
}

resource "azurerm_resource_group" "rg"{
    name = "az104-rg2"
    location = "East US"
    tags = {
        CostCenter = "000"
    }
}
data "azurerm_policy_definition" "require_tag"{
    display_name  = "Require a tag and its value on resources"
}
resource "azurerm_policy_assignment" "require_tag_assignment"{
    name = "RequireCostCenterTag"
    scope = azurerm_resource_group.rg.id
    policy_definition_id = data.azurerm_policy_definition.require_tag.id

    parameters = jsonencode({
        tagName = {
            value = "CostCenter"
        },
        tagValue = {
            value = "000"
        }
    })
}

data "azurerm_policy_definition" "inherit_tag" {
    display_name  = "Inherit a tag from the resource group if missing"
}

resource "azurerm_policy_assignment" "inherit_tag_assignment" {
    name = "InheritCostCenterTag"
    scope = azurerm_resource_group.rg.id
    policy_definition_id = data.azurerm_policy_definition.inherit_tag.id

    parameters = jsonencode({
        tagName = {
            value = "CostCenter"
        }
    })
}

resource "azurerm_policy_remediation" "remediation_inherit" {
    name = "remediateInheritCostCenter"
    policy_assignment_id = azurerm_policy_assignment.inherit_tag_assignment.id
    resource_discovery_mode = "ExistingNonCompliant"
}

resource "azurerm_management_lock" "rg_delete_lock"{
    name = "rg-lock"
    scope = azurerm_resource_group.rg.id
    lock_level = "CanNotDelete"
}