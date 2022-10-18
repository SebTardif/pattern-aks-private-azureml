output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "firewall" {
  value = {
    fqdn       = module.firewall.fqdn
    ip_address = module.firewall.public_ip_address
  }
}


output "aks_cluster_name" {
  value = module.aks-1.cluster_name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
