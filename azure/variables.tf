# provider
variable "azure_subscription" {
  type    = "string"
}

variable "azure_client" {
  type    = "string"
}

variable "azure_secret" {
  type    = "string"
}

variable "azure_tenant" {
  type    = "string"
}

# resource
variable "resource_name" {
  type    = "string"
  default = "owncloud"
}

variable "resource_region" {
  type    = "string"
  default = "East US"
}

# server
variable "server_type" {
  type    = "string"
  default = "Standard_DS1_v2"
}

variable "server_name" {
  type    = "string"
  default = "owncloud"
}

variable "server_admin" {
  type    = "string"
  default = "owncloud"
}

variable "server_password" {
  type    = "string"
  default = "owncloud!234"
}

# scripting
variable "artifacts_location" {
  type    = "string"
  default = "https://raw.githubusercontent.com/owncloud/terraform/master/azure/scripts"
}

# owncloud
variable "owncloud_admin" {
  type    = "string"
  default = "admin"
}

variable "owncloud_password" {
  type    = "string"
  default = "admin"
}

variable "owncloud_domain" {
  type    = "string"
  default = "owncloud.local"
}
