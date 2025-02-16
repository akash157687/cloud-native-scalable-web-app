# Provider Block
provider "azurerm" {
  features {}

  subscription_id = "9685f03f-0b8d-47fa-9b5a-b6ea0abb0807"  # Replace with actual Subscription ID
}


# Resource Group
resource "azurerm_resource_group" "devops_rg" {
  name     = "devops-project-rg"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "devops_vnet" {
  name                = "devops-vnet"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "devops_subnet" {
  name                 = "devops-subnet"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for VM
resource "azurerm_public_ip" "devops_public_ip" {
  name                = "devops-public-ip"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface for VM
resource "azurerm_network_interface" "devops_nic" {
  name                = "devops-nic"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_public_ip.id
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "devops_vm" {
  name                  = "devops-vm"
  location              = azurerm_resource_group.devops_rg.location
  resource_group_name   = azurerm_resource_group.devops_rg.name
  network_interface_ids = [azurerm_network_interface.devops_nic.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "devops-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "devopsvm"
    admin_username = "azureuser"
    admin_password = "newpassword1789"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devops-aks"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  dns_prefix          = "devopsaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "devopsacr157687"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  sku                 = "Basic"
}

