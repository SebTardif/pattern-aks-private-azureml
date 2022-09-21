resource "azurerm_network_interface" "dnsForwarder" {
  name                = "${local.hostname}-dnsForwarder-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.255.0.134"
  }
}

resource "azurerm_linux_virtual_machine" "dnsForwarder" {
  name                = "${local.hostname}-dnsForwarder"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = var.sku
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.dnsForwarder.id,
  ]

  custom_data = base64encode(templatefile("${path.module}/config/cloud-init.yaml", {
    bind9conf = local.bind9conf
  }))

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "dnsForwarder" {
  name                = "dnsForwarderNSG"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  security_rule {
    name                       = "AllowEverything"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "dnsForwarder" {
  network_interface_id      = azurerm_network_interface.dnsForwarder.id
  network_security_group_id = azurerm_network_security_group.dnsForwarder.id
}
