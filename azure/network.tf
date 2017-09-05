resource "azurerm_virtual_network" "owncloud" {
  name                = "${var.resource_name}"
  address_space       = ["10.0.0.0/16"]
  location               = "${azurerm_resource_group.owncloud.location}"
  resource_group_name    = "${azurerm_resource_group.owncloud.name}"
}

resource "azurerm_subnet" "owncloud" {
  name                 = "${var.resource_name}"
  resource_group_name    = "${azurerm_resource_group.owncloud.name}"
  virtual_network_name = "${azurerm_virtual_network.owncloud.name}"
  address_prefix       = "10.0.2.0/24"
}
