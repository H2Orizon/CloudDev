terraform{
    required_providers {
      azuread = {
        source = "hashicorp/azuread"
        version = "~> 3.0.2"
      }
      random = {
        source  = "hashicorp/random"
        version = "~> 3.6"
      }
    }
    required_version = ">= 1.1.0"
}

provider "azuread"{
    features {}
}

data "azuread_client_config" "current" {}