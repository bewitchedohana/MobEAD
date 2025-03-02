terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "mobead" {
  name     = "mobead-resources"
  location = "westus2"
}

resource "azurerm_virtual_network" "mobead-virtual-network" {
  name                = "mobead-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
}

resource "azurerm_subnet" "mobead-internal-network" {
  name                 = "mobead-internal-network"
  resource_group_name  = azurerm_resource_group.mobead.name
  virtual_network_name = azurerm_virtual_network.mobead-virtual-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "mobead-network-interface" {
  name                = "mobead-network-interface"
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mobead-internal-network.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.32"
    public_ip_address_id          = azurerm_public_ip.mobead-public-ip.id
  }
}

resource "azurerm_windows_virtual_machine" "mobead-vm" {
  name                  = "mobead-vm"
  resource_group_name   = azurerm_resource_group.mobead.name
  location              = azurerm_resource_group.mobead.location
  size                  = "Standard_F2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.mobead-network-interface.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_ssh_public_key" "mobead-public-key" {
  name                = "mobead-public-key"
  resource_group_name = azurerm_resource_group.mobead.name
  location            = azurerm_resource_group.mobead.location
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_public_ip" "mobead-public-ip" {
  name                    = "mobead-public-ip"
  location                = azurerm_resource_group.mobead.location
  resource_group_name     = azurerm_resource_group.mobead.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  lifecycle {
    create_before_destroy = true
  }
}

data "azurerm_public_ip" "public-ip-data" {
  name                = azurerm_public_ip.mobead-public-ip.name
  resource_group_name = azurerm_windows_virtual_machine.mobead-vm.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.public-ip-data.ip_address
}