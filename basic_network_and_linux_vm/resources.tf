resource "azurerm_resource_group" "test_resource_group" {
    name = "rg-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
    location = var.location
    tags = local.tags
}

resource "tls_private_key" "linux_ssh_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pip-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
  resource_group_name = azurerm_resource_group.test_resource_group.name
  location            = azurerm_resource_group.test_resource_group.location
  allocation_method   = "Static"

  tags = local.tags
}

resource "azurerm_virtual_network" "linux_vnet" {
    name = "vnet-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
    resource_group_name = azurerm_resource_group.test_resource_group.name
    location = azurerm_resource_group.test_resource_group.location
    address_space = ["10.155.0.0/16"]
    tags = local.tags
}

resource "azurerm_subnet" "linux_subnet" {
    name = "internal"
    resource_group_name = azurerm_resource_group.test_resource_group.name
    virtual_network_name = azurerm_virtual_network.linux_vnet.name
    address_prefixes = ["10.155.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
  location            = azurerm_resource_group.test_resource_group.location
  resource_group_name = azurerm_resource_group.test_resource_group.name

  security_rule {
    name                       = "AllowRestrictedSshInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.nsg_allowed_ip_addresses
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_network_interface" "vm_interface" {
    name = "nic-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
    location = azurerm_resource_group.test_resource_group.location
    tags = local.tags
    resource_group_name = azurerm_resource_group.test_resource_group.name

    ip_configuration {
      name = "configuration"
      subnet_id = azurerm_subnet.linux_subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.vm_public_ip.id
    }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.vm_interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "linux_vm" {
    name = "vm-${var.location_shorthand[var.location]}-${var.workload_identifier}-01"
    location = azurerm_resource_group.test_resource_group.location
    tags = local.tags
    resource_group_name = azurerm_resource_group.test_resource_group.name
    network_interface_ids = [azurerm_network_interface.vm_interface.id]

    vm_size = "Standard_B2s_v2"

    storage_os_disk {
        name = "vm-${var.location_shorthand[var.location]}-${var.workload_identifier}-01-OsDisk"
        caching = "None"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    delete_os_disk_on_termination = true

    storage_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"
    }

    os_profile {
        computer_name = "mattjohnson"
        admin_username = "matt"
    }

    os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
        path = "/home/matt/.ssh/authorized_keys"
        key_data = tls_private_key.linux_ssh_key.public_key_openssh
      }
    }
}