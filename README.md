# Project Details

## Title

Provision Azure PaaS and IaaS resources to achieve a scalable deployment of Microsoft IIS web servers which are fronted by Azure Traffic Manager (for multi-region failover) and Azure Application Gateway (for single-region load balancing).

## Description

Scalable Azure multi-region deployment of Microsoft IIS web servers across UK South and North Europe. Web servers are fronted by Azure Traffic Manager (for multi-region failover) and Azure Application Gateway (for single-region load balancing). Additionally, there is a NAT Gateway for outbound traffic, Key Vault for BitLocker disk encryption on the web servers, and storage accounts for boot diagnostics. Intention of this project is to demonstrate a multi-region deployment, which has an easily scalable web server instance count in each region using variables. Simply updating the variable will provision (or deprovision) the instances, disks, network interfaces, and relationship to the Application Gateway. The Microsoft IIS role is also automatically installed on the instances using an extension. This Terraform will provide the complete underlying infrastructure, allowing you to deploy your web application afterwards.

![Architecture Diagram](https://github.com/cbchalmers/Azure-IaaS-TrafficManager-AppGateway-WebServers/blob/master/diagrams/azure_architecture.jpg)

#### Resources Provisioned

* Azure Multi-Region UK South and North Europe
* Virtual Networks, Subnets, Network Security Groups
* Traffic Manager Profile
* Application Gateways
* Key Vaults for BitLocker Encryption
* Storage Accounts for Boot Diagnostics
* Windows Server 2019 Core Instances
* Bootstrap Instances with IIS Role

### Prerequisites

* [Download and Install Terraform](https://www.terraform.io/downloads.html)
* [Create a Service Principal for Terraform](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html#creating-a-service-principal)

### Installing

* Populate client_id and client_secret inside main.tf from the Service Principal you created in the prerequisites
* Populate subscription_id and tenant_id inside main.tf from your Azure tenant information
* Populate resource_location, resource_prefix, web_instance_count and web_instance_size inside main.tf as appropriate for each module
* Populate resource_tags inside vars.tf with any key:value you want to apply onto all resources
* Populate trusted_ip_addresses inside vars.tf with your IP addresses which should be allowed to access the Key Vault
* Populate instance_admin_username_temp and instance_admin_password_temp inside vars.tf with appropriate values which will be used to log into the instance

The [terraform init](https://www.terraform.io/docs/commands/init.html) command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times

```
terraform init
```

The [terraform plan](https://www.terraform.io/docs/commands/plan.html) command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files. This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state. For example, terraform plan might be run before committing a change to version control, to create confidence that it will behave as expected.

```
terraform plan
```

The [terraform apply](https://www.terraform.io/docs/commands/apply.html) command is used to apply the changes required to reach the desired state of the configuration, or the pre-determined set of actions generated by a terraform plan execution plan.

```
terraform apply
```

### Removing

The [terraform destroy](https://www.terraform.io/docs/commands/destroy.html) command is used to destroy the Terraform-managed infrastructure.

```
terraform destroy
```

## Built With

* [Terraform Azure RM Provider](https://www.terraform.io/docs/providers/azurerm/index.html)

## References

* [Terraform Commands](https://www.terraform.io/docs/commands/index.html)
* [Terraform Azure RM Provider](https://www.terraform.io/docs/providers/azurerm/index.html)

## Authors

Chris Chalmers - [LinkedIn](https://uk.linkedin.com/in/chris-chalmers), [Azure DevOps](https://dev.azure.com/cbchalmers/Personal%20Development), [GitHub](https://github.com/cbchalmers)

# Auto Generated by [terraform-docs](https://github.com/terraform-docs/terraform-docs)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| azurerm | >= 2.29.0 |
| random | >= 2.3.0 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_admin_password_temp | Appropriate value which will be used to log into the instance | `string` | n/a | yes |
| instance_admin_username_temp | Appropriate value which will be used to log into the instance | `string` | n/a | yes |
| resource_tags | Desired tags which should be applied to all resources | `map` | <pre>{<br>  "Environment": "Development",<br>  "ProvisionedWith": "Terraform"<br>}</pre> | no |
| trusted_ip_addresses | Your public IP address. This will allow whitelisted access to the Key Vault | `list(string)` | n/a | yes |

## Outputs

No output.

