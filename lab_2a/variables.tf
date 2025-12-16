variable "entra_group_name" {
description = "Name of the Entra ID group"
type = string
default = "az104-lab02a-readers"
}


variable "role_name" {
description = "RBAC role to assign"
type = string
default = "Reader"
}