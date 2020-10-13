variable "resource_location" {
  description = "Desired location to provision the resources. Eg UK South"
  type        = string
}

variable "resource_prefix" {
  description = "Desired prefix for the provisioned resources. Eg CC-D-GBL"
  type        = string
}

variable "resource_tags" {
  description = "Desired tags which should be applied to all resources"
  type        = map
}

variable "public_ip_app_gateway_uks_id" {
  description = "Resource ID of Application Gateway deployed into UK South"
  type        = string
}

variable "public_ip_app_gateway_neu_id" {
  description = "Resource ID of Application Gateway deployed into North Europe"
  type        = string
}