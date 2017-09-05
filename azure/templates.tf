data "template_file" "settings" {
  depends_on = ["azurerm_public_ip.owncloud"]
  template = "${file("scripts/settings.json")}"

  vars {
    artifacts_location = "${var.artifacts_location}"
    owncloud_admin = "${var.owncloud_admin}"
    owncloud_password = "${var.owncloud_password}"
    owncloud_domain = "${var.owncloud_domain}"
  }
}

data "template_file" "provision" {
  depends_on = ["azurerm_public_ip.owncloud"]
  template = "${file("scripts/provision.json")}"

  vars {
    artifacts_location = "${var.artifacts_location}"
    owncloud_admin = "${var.owncloud_admin}"
    owncloud_password = "${var.owncloud_password}"
    owncloud_domain = "${var.owncloud_domain}"
  }
}
