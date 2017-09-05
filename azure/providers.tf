provider "azurerm" {
  subscription_id = "${var.azure_subscription}"
  client_id       = "${var.azure_client}"
  client_secret   = "${var.azure_secret}"
  tenant_id       = "${var.azure_tenant}"
}
