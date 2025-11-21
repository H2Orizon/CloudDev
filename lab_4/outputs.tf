output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "core_vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "manufacturing_vnet_id" {
  value = azurerm_virtual_network.vnet2.id
}
output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}