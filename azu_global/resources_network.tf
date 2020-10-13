resource "random_string" "random" {
  length  = 12
  lower   = true
  upper   = false
  special = false
  number  = false
}

#########################################################################################################
##### Traffic Managers
#########################################################################################################

resource "azurerm_traffic_manager_profile" "traffic_manager_profile_web" {
  name                   = "${var.resource_prefix}-WEB-tm"
  resource_group_name    = azurerm_resource_group.resource_group_network_services.name
  traffic_routing_method = "Performance"
  tags                   = var.resource_tags

  dns_config {
    relative_name = random_string.random.result
    ttl           = 30
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

#########################################################################################################
##### Traffic Manager Endpoints
#########################################################################################################

resource "azurerm_traffic_manager_endpoint" "traffic_manager_endpoint_application_gateway_uks" {
  name                = "${var.resource_prefix}-WEB-UKS-te"
  resource_group_name = azurerm_resource_group.resource_group_network_services.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager_profile_web.name
  endpoint_status     = "Enabled"
  type                = "azureEndpoints"
  target_resource_id  = var.public_ip_app_gateway_uks_id
  weight              = 100
}

resource "azurerm_traffic_manager_endpoint" "traffic_manager_endpoint_application_gateway_neu" {
  name                = "${var.resource_prefix}-WEB-NEU-te"
  resource_group_name = azurerm_resource_group.resource_group_network_services.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager_profile_web.name
  endpoint_status     = "Enabled"
  type                = "azureEndpoints"
  target_resource_id  = var.public_ip_app_gateway_neu_id
  weight              = 100
}