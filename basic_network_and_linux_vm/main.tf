terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


locals {
    tags = {
        Provider = "Terraform"
        CostCenter = var.cost_center
        CostUnit = var.cost_unit
        CreationDate = formatdate("YYYY-MM-DD",timestamp())
        Creator = var.user_email
    }
}