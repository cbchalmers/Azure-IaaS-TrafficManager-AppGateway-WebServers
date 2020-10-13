variable "resource_location" {
  description = "Desired location to provision the resources. Eg UK South"
  type        = string
}

variable "resource_prefix" {
  description = "Desired prefix for the provisioned resources. Eg CC-D-UKS"
  type        = string
}

variable "resource_tags" {
  description = "Desired tags which should be applied to all resources"
  type        = map
}

variable "trusted_ip_addresses" {
  description = "Your public IP address. This will allow whitelisted access to the Key Vault"
  type        = list(string)
}

variable "web_instance_count" {
  description = "Number of web server instances to deploy"
  type        = number
}

variable "web_instance_size" {
  description = "Size of web server instances to deploy"
  type        = string
}

variable "instance_admin_username_temp" {
  description = "Appropriate value which will be used to log into the instance"
  type        = string
}

variable "instance_admin_password_temp" {
  description = "Appropriate value which will be used to log into the instance"
  type        = string
}