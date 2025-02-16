resource "azurerm_private_dns_zone" "hub" {
  name                = local.zone_name
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hubDnsLink"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.hub.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "acr-privatelink"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.default.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr-aks1" {
  name                  = "acr-privatelink-aks1"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.aks-1-vnet.id
}

resource "azurerm_private_dns_zone" "aksPrivateZone" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aksPrivateZoneDefaultVnet" {
  name                  = "aks-privatelink-default"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.aksPrivateZone.name
  virtual_network_id    = azurerm_virtual_network.default.id
}

resource "azurerm_private_dns_zone" "akv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkvault" {
  name                  = "akv-privatelink"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.akv.name
  virtual_network_id    = azurerm_virtual_network.default.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkvault-aks1" {
  name                  = "akv-privatelink-aks1"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.akv.name
  virtual_network_id    = azurerm_virtual_network.aks-1-vnet.id
}

