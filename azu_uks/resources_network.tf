resource "random_string" "string_dns" {
  length  = 24
  lower   = true
  upper   = false
  special = false
  number  = false
}

#########################################################################################################
##### Virtual Networks
#########################################################################################################

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.resource_prefix}-vn"
  resource_group_name = azurerm_resource_group.resource_group_network_services.name
  location            = azurerm_resource_group.resource_group_network_services.location
  address_space       = ["172.16.0.0/16"]
  tags                = var.resource_tags
}

#########################################################################################################
##### Subnets
#########################################################################################################

resource "azurerm_subnet" "subnet_app_gateways" {
  name                 = "${var.resource_prefix}-APP-GATEWAYS-sn"
  resource_group_name  = azurerm_resource_group.resource_group_network_services.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet" "subnet_web_front_tier_services" {
  name                 = "${var.resource_prefix}-WEB-FRONT-SERVICES-sn"
  resource_group_name  = azurerm_resource_group.resource_group_network_services.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["172.16.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault","Microsoft.Storage","Microsoft.Sql"]
}

#########################################################################################################
##### Security Groups
#########################################################################################################

resource "azurerm_network_security_group" "security_group_web_front_tier_services" {
  name                = "${var.resource_prefix}-WEB-FRONT-SERVICES-ns"
  resource_group_name = azurerm_resource_group.resource_group_network_services.name
  location            = azurerm_resource_group.resource_group_network_services.location
  tags                = var.resource_tags
}

#########################################################################################################
##### Security Group Associations
#########################################################################################################

resource "azurerm_subnet_network_security_group_association" "security_group_assoc_web_front_tier_services" {
  subnet_id                 = azurerm_subnet.subnet_web_front_tier_services.id
  network_security_group_id = azurerm_network_security_group.security_group_web_front_tier_services.id
}

#########################################################################################################
##### Public IPs
#########################################################################################################

resource "azurerm_public_ip" "public_ip_app_gateway" {
  name                    = "${var.resource_prefix}-APP-GWY-ip"
  resource_group_name     = azurerm_resource_group.resource_group_network_services.name
  location                = azurerm_resource_group.resource_group_network_services.location
  sku                     = "Basic"
  idle_timeout_in_minutes = 30
  allocation_method       = "Dynamic"
  domain_name_label       = random_string.string_dns.result
  tags                    = var.resource_tags
}

resource "azurerm_public_ip" "public_ip_nat_gateway" {
  name                    = "${var.resource_prefix}-NAT-GWY-ip"
  resource_group_name     = azurerm_resource_group.resource_group_network_services.name
  location                = azurerm_resource_group.resource_group_network_services.location
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
  allocation_method       = "Static"
  tags                    = var.resource_tags
}

#########################################################################################################
##### NAT Gateways
#########################################################################################################

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${var.resource_prefix}-WEB-NAT-ng"
  resource_group_name     = azurerm_resource_group.resource_group_network_services.name
  location                = azurerm_resource_group.resource_group_network_services.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 60
  tags                    = var.resource_tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.public_ip_nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat_gateway_association_web_front_tier_services" {
  subnet_id      = azurerm_subnet.subnet_web_front_tier_services.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

#########################################################################################################
##### Application Gateways
#########################################################################################################


locals {
  backend_address_pool_name      = "${var.resource_prefix}-WEB-backend-pool"
  frontend_port_name             = "${var.resource_prefix}-WEB-frontend-port"
  frontend_ip_configuration_name = "${var.resource_prefix}-WEB-frontend-ip"
  http_setting_name              = "${var.resource_prefix}-WEB-http-settings"
  listener_name                  = "${var.resource_prefix}-WEB-http-lisstener"
  request_routing_rule_name      = "${var.resource_prefix}-WEB-routing-rule"
  redirect_configuration_name    = "${var.resource_prefix}-WEB-redirect-config"
}

resource "azurerm_application_gateway" "application_gateway_web" {
  name                = "${var.resource_prefix}-WEB-ag"
  resource_group_name = azurerm_resource_group.resource_group_network_services.name
  location            = azurerm_resource_group.resource_group_network_services.location
  tags                = var.resource_tags

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "AppGatewayIpConfiguration"
    subnet_id = azurerm_subnet.subnet_app_gateways.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip_app_gateway.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "network_interface_application_gateway_backend_address_pool_association_web" {
  count                   = var.web_instance_count
  network_interface_id    = azurerm_network_interface.network_interface_web[count.index].id
  ip_configuration_name   = "IPCONFIG1"
  backend_address_pool_id = azurerm_application_gateway.application_gateway_web.backend_address_pool[0].id
}