locals {
  vm_count = 3
  vm_names = ["az104-06-vm0","az104-06-vm1","az104-06-vm2"]
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-06-vnet1"
  address_space       = ["10.60.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_vm0" {
  name                 = "subnet-vm0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.1.0/24"]
}
resource "azurerm_subnet" "subnet_vm1" {
  name                 = "subnet-vm1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.2.0/24"]
}
resource "azurerm_subnet" "subnet_vm2" {
  name                 = "subnet-vm2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.4.0/24"]
}

resource "azurerm_subnet" "subnet_appgw" {
  name                 = "subnet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.3.224/27"]
}

resource "azurerm_public_ip" "lb_pip" {
  name                = "az104-lbpip-tf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "az104-lb-tf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "az104-fe"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_be" {
  name                = "az104-be"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "az104-hp"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "az104-lbrule"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "az104-fe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_be.id
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

resource "azurerm_network_interface" "nic" {
  count               = local.vm_count
  name                = "nic-${local.vm_names[count.index]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = element([azurerm_subnet.subnet_vm0.id, azurerm_subnet.subnet_vm1.id, azurerm_subnet.subnet_vm2.id], count.index)
    private_ip_address_allocation = "Static"
    private_ip_address            = element(["10.60.1.4","10.60.2.4","10.60.4.4"], count.index)

    load_balancer_backend_address_pool_ids = count.index < 2 ? [azurerm_lb_backend_address_pool.lb_be.id] : []
  }
}

locals {
  cloud_init = <<EOF
#cloud-config
runcmd:
 - echo "Hello World from ${HOSTNAME}" > /var/www/html/index.html || true
 - apt-get update; apt-get install -y apache2 || true
 - systemctl enable apache2
 - systemctl start apache2
EOF
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = local.vm_count
  name                = local.vm_names[count.index]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = "" 
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = local.cloud_init
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "az104-gwpip-tf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "az104-appgw-tf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "gatewayip"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }
  frontend_port {
    name = "httpPort"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "publicFrontend"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "az104-appgwbe"
    ip_addresses = [azurerm_network_interface.nic[0].ip_configuration[0].private_ip_address, azurerm_network_interface.nic[1].ip_configuration[0].private_ip_address]
  }

  backend_address_pool {
    name = "az104-imagebe"
    ip_addresses = [azurerm_network_interface.nic[0].ip_configuration[0].private_ip_address]
  }
  backend_address_pool {
    name = "az104-videobe"
    ip_addresses = [azurerm_network_interface.nic[1].ip_configuration[0].private_ip_address]
  }

  http_settings {
    name                    = "az104-http"
    cookie_based_affinity   = "Disabled"
    port                    = 80
    protocol                = "Http"
    request_timeout         = 30
  }

  listener {
    name                           = "az104-listener"
    frontend_ip_configuration_name = "publicFrontend"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  url_path_map {
    name               = "az104-urlmap"
    default_backend_address_pool_name = "az104-appgwbe"
    default_backend_http_settings_name = "az104-http"

    path_rule {
      name                       = "images"
      paths                      = ["/image/*"]
      backend_address_pool_name  = "az104-imagebe"
      backend_http_settings_name = "az104-http"
    }

    path_rule {
      name                       = "videos"
      paths                      = ["/video/*"]
      backend_address_pool_name  = "az104-videobe"
      backend_http_settings_name = "az104-http"
    }
  }

  request_routing_rule {
    name                       = "az104-gwrule"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "az104-listener"
    url_path_map_name          = "az104-urlmap"
  }

  tags = {
    env = "lab"
  }
}
