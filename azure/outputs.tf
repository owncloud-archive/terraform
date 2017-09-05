output "ip" {
  value = "${azurerm_public_ip.owncloud.ip_address}"
}

output "ssh" {
  value = "${var.server_admin}@${azurerm_public_ip.owncloud.ip_address}"
}
