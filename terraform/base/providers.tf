terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.22.0"
    }
    azuread = {
      version = ">= 2.28.1"
    }
    kubernetes = {
      version = ">= 2.13.1"
    }
  }
}

provider "azurerm" {
  features {}
}