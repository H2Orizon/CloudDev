variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "az104-rg7"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "storage_account_name" {
  type        = string
  description = "Unique name for storage account (3-24 chars, lowercase, letters+digits)"
  default     = "az104storageacc123"
}
