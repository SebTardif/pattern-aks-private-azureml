output "private_ip_address" {
  value = azurerm_network_interface.example.ip_configuration[0].private_ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value = var.admin_password
}