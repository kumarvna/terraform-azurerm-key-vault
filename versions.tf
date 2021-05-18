terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}
