provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {
  }
}

module "azu_uks" {
  source                       = "./azu_uks"
  resource_location            = "UK South"
  resource_prefix              = "CC-D-UKS"
  resource_tags                = var.resource_tags
  web_instance_count           = 2
  web_instance_size            = "Standard_B2ms"
  trusted_ip_addresses         = var.trusted_ip_addresses
  instance_admin_username_temp = var.instance_admin_username_temp
  instance_admin_password_temp = var.instance_admin_password_temp
}

module "azu_neu" {
  source                       = "./azu_neu"
  resource_location            = "North Europe"
  resource_prefix              = "CC-D-NEU"
  web_instance_count           = 1
  web_instance_size            = "Standard_B2ms"
  resource_tags                = var.resource_tags
  trusted_ip_addresses         = var.trusted_ip_addresses
  instance_admin_username_temp = var.instance_admin_username_temp
  instance_admin_password_temp = var.instance_admin_password_temp
}

module "azu_global" {
  source                       = "./azu_global"
  resource_location            = "UK South"
  resource_prefix              = "CC-D-GBL"
  resource_tags                = var.resource_tags
  public_ip_app_gateway_uks_id = module.azu_uks.public_ip_app_gateway_uks_id
  public_ip_app_gateway_neu_id = module.azu_neu.public_ip_app_gateway_neu_id
}