locals {
  tags = {
    tier = var.tier
    deployment = var.deployment
  }
}


provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  features {}
}
terraform {
  backend "azurerm" {
    ## Udacity's original fields
    # storage_account_name = "tfstate23042"
    # container_name       = "tfstate"
    # key                  = ""
    # access_key           = ""

    ## Fields mentioned in the documentation
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate23042"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
module "resource_group" {
  source               = "./modules/resource_group"
  resource_group       = "${var.resource_group}"
  location             = "${var.location}"
}

# Reference the AppService Module here.
module "appservice" {
  source = "./modules/appservice"

  name = var.application_type
  resource_group_name = var.resource_group
  location = var.location
  tags = local.tags
}
