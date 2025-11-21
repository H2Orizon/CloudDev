variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  default = "az104-rg"
}

variable "vnet_name" {
  type    = string
  default = "CoreServicesVnet"
}
variable "address_space" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}
variable "subnet1_name" {
  type    = string
  default = "SharedServicesSubnet"
}
variable "subnet1_prefix" {
  type    = string
  default = "10.20.10.0/24"
}
variable "subnet2_name" {
  type    = string
  default = "DatabaseSubnet"
}
variable "subnet2_prefix" {
  type    = string
  default = "10.20.20.0/24"
}

variable "vnet2_name" {
  type    = string
  default = "ManufacturingVnet"
}
variable "vnet2_address_space" {
  type    = list(string)
  default = ["10.30.0.0/16"]
}
variable "subnet3_name" {
  type    = string
  default = "SensorSubnet1"
}
variable "subnet3_prefix" {
  type    = string
  default = "10.30.20.0/24"
}
variable "subnet4_name" {
  type    = string
  default = "SensorSubnet2"
}
variable "subnet4_prefix" {
  type    = string
  default = "10.30.21.0/24"
}

variable "nsg_name" {
  type    = string
  default = "myNSGSecure"
}

variable "private_dns_zone_name" {
  type    = string
  default = "contoso.internal"
}
