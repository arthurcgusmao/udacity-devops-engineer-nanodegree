provider "azurerm" {
  features {}
}

locals {
  prefix = "${var.name}-${var.environment}"
  tags = {
    app = var.name
    environment = var.environment
  }
}

resource "azurerm_resource_group" "app" {
  name     = "${local.prefix}-rg"
  location = var.location

  tags = local.tags
}


# VIRTUAL NETWORK CONFIGS

resource "azurerm_virtual_network" "app" {
  name                = "${local.prefix}-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
}
resource "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_network_security_group" "app" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  security_rule {
    name                       = "AllowOutboundInternalTraffic"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "DenyInboundExternalTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}


# LOAD BALANCER CONFIGS

resource "azurerm_public_ip" "app" {
  name                = "${local.prefix}-publicIpForLB"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  allocation_method   = "Static"
}
resource "azurerm_lb" "app" {
  name                = "${local.prefix}-loadBalancer"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.app.id
  }
}
resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "BackEndAddressPool"
}


# VIRTUAL MACHINE CONFIGS

resource "azurerm_availability_set" "app" {
  name                = "${local.prefix}-aset"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
}

resource "azurerm_network_interface" "app" {
  count = var.replicas

  name                = "${local.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.app.id  # In this example, the NIC connects to the Load Balancer
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "app" {
  count = var.replicas

  backend_address_pool_id = azurerm_lb_backend_address_pool.app.id
  network_interface_id    = azurerm_network_interface.app[count.index].id
  ip_configuration_name   = "internal"
}
resource "azurerm_linux_virtual_machine" "app" {
  count = var.replicas

  name                            = "${local.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.app.name
  location                        = azurerm_resource_group.app.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.app[count.index].id]
  availability_set_id = azurerm_availability_set.app.id

  # source_image_id = azurerm_managed_disk.app[count.index].id
  source_image_id = "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf/resourceGroups/project1-dev-rg/providers/Microsoft.Compute/images/project1-vm-image"

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = local.tags
}
resource "azurerm_managed_disk" "app" {
  count = var.replicas

  name                 = "${local.prefix}-managed-disk-${count.index}"
  resource_group_name  = azurerm_resource_group.app.name
  location             = azurerm_resource_group.app.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = "1"
  # create_option        = "FromImage"
  # image_reference_id   = "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf/resourceGroups/PROJECT1-DEV-RG/providers/Microsoft.Compute/images/project1-vm-image"
  create_option        = "Empty"
}
resource "azurerm_virtual_machine_data_disk_attachment" "app" {
  count = var.replicas

  managed_disk_id    = azurerm_managed_disk.app[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.app[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}
