variable "location" {
  type    = string
  default = "EastUS"
}
variable "rg_name" {
  type    = string
  default = "az104-rg6-terraform"
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "admin_password" {
  type    = string
  description = "Use a secure password (or switch to SSH keys)."
  type = string
}
