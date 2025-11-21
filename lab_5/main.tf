provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}


resource "azurerm_virtual_network" "core_vnet" {
    name = "CoreServicesVnet"
    address_space = ["10.0.0.0/16"]
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "core_subnet" {
    name = "Core"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.core_vnet.name
    address_prefixes = ["10.0.0.0/24"]
}


resource "azurerm_network_interface" "core_nic" {
    name = "coreNic"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.core_subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_windows_virtual_machine" "core_vm" {
    name = "CoreServicesVM"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    size = "Standard_DS2_v3"
    admin_username = var.admin_username
    admin_password = var.admin_password
    network_interface_ids = [azurerm_network_interface.core_nic.id]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "latest"
    }
}


resource "azurerm_virtual_network" "manu_vnet" {
    name = "ManufacturingVnet"
    address_space = ["172.16.0.0/16"]
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "manu_subnet" {
  name = "Manufacturing"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manu_vnet.name
  address_prefixes = ["172.16.0.0/24"]
}