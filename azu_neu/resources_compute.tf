#########################################################################################################
##### Availability Sets
#########################################################################################################

resource "azurerm_availability_set" "availability_set_web" {
  name                        = "${var.resource_prefix}-WEB-as"
  resource_group_name         = azurerm_resource_group.resource_group_web_front_tier_services.name
  location                    = azurerm_resource_group.resource_group_web_front_tier_services.location
  platform_fault_domain_count = 2 # UK West only has 2 fault domains. TF defaults to 3
  tags                        = var.resource_tags
}

#########################################################################################################
##### Network Interfaces
#########################################################################################################

resource "azurerm_network_interface" "network_interface_web" {
  count               = var.web_instance_count
  name                = "${var.resource_prefix}-WEB0${count.index + 1}-ni"
  location            = azurerm_resource_group.resource_group_web_front_tier_services.location
  resource_group_name = azurerm_resource_group.resource_group_web_front_tier_services.name
  tags                = var.resource_tags

  ip_configuration {
    name                          = "IPCONFIG1"
    subnet_id                     = azurerm_subnet.subnet_web_front_tier_services.id
    private_ip_address_allocation = "Dynamic"
  }
}

#########################################################################################################
##### Virtual Machines
#########################################################################################################

resource "azurerm_windows_virtual_machine" "virtual_machine_web" {
  count                 = var.web_instance_count
  name                  = "${var.resource_prefix}-WEB0${count.index + 1}"
  resource_group_name   = azurerm_resource_group.resource_group_web_front_tier_services.name
  location              = azurerm_resource_group.resource_group_web_front_tier_services.location
  size                  = var.web_instance_size
  availability_set_id   = azurerm_availability_set.availability_set_web.id
  timezone              = "GMT Standard Time"
  tags                  = var.resource_tags
  admin_username        = var.instance_admin_username_temp
  admin_password        = var.instance_admin_password_temp
  network_interface_ids = [
    azurerm_network_interface.network_interface_web[count.index].id,
  ]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    #disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption_set.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-Core-smalldisk"
    version   = "latest"
  }

  boot_diagnostics {
      storage_account_uri = azurerm_storage_account.storage_account_boot_diag.primary_blob_endpoint
  }

}

#########################################################################################################
##### Managed Disks
#########################################################################################################

resource "azurerm_managed_disk" "managed_disk_web_s" {
  count                = var.web_instance_count
  name                 = "${var.resource_prefix}-WEB0${count.index + 1}_DataDisk_S"
  location             = azurerm_resource_group.resource_group_web_front_tier_services.location
  resource_group_name  = azurerm_resource_group.resource_group_web_front_tier_services.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 20
  tags                 = var.resource_tags
}

#########################################################################################################
##### Managed Disk Attachments
#########################################################################################################

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_data_disk_attachment_web_s" {
  count              = var.web_instance_count
  managed_disk_id    = azurerm_managed_disk.managed_disk_web_s[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine_web[count.index].id
  lun                = "11"
  caching            = "ReadWrite"
}

#########################################################################################################
##### Virtual Machine Extensions
#########################################################################################################

resource "azurerm_virtual_machine_extension" "virtual_machine_extension_web_front" {
  count                = var.web_instance_count
  name                 = "BootstrapWebFront"
  virtual_machine_id   = azurerm_windows_virtual_machine.virtual_machine_web[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  tags                 = var.resource_tags

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Http-Redirect, Web-ASP, Web-Asp-Net, Web-Net-Ext, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, Web-Http-Logging, Web-Request-Monitor, Web-ODBC-Logging, Web-Basic-Auth, Web-Windows-Auth, Web-Filtering, Web-IP-Security, Web-Stat-Compression, Web-Dyn-Compression, Web-Mgmt-Tools, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Web-WMI, Web-Scripting-Tools, Web-Mgmt-Service, Web-Asp-Net45, Web-Net-Ext45; exit 0;\""
    }
  SETTINGS
}