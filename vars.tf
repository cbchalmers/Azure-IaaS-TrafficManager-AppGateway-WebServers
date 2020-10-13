variable "resource_tags" {
  description = "Desired tags which should be applied to all resources"
  type        = map
  default     = {
    Environment     = "Development"
    ProvisionedWith = "Terraform"
  }
}

variable "trusted_ip_addresses" {
  description = "Your public IP address. This will allow whitelisted access to the Key Vault"
  type        = list(string)
#  default     = ["1.1.1.1/32","2.2.2.2/32"]
}

variable "instance_admin_username_temp" {
  description = "Appropriate value which will be used to log into the instance"
  type        = string
#  default     = "changem"
}

variable "instance_admin_password_temp" {
  description = "Appropriate value which will be used to log into the instance"
  type        = string
#  default     = "changeme"
}