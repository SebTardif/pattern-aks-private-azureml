# data "azurerm_user_assigned_identity" "managed-id" {
#   name                = "aks-user-assigned-managed-id"
#   resource_group_name = var.resource_group.name
# }

resource "azurerm_kubernetes_cluster" "dev" {
  name                = var.cluster_name == true ? var.cluster_name : local.cluster_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  dns_prefix = local.cluster_name

  kubernetes_version      = var.aks_settings.kubernetes_version
  private_cluster_enabled = var.aks_settings.private_cluster_enabled

  default_node_pool {
    name                = var.default_node_pool.name
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.subnet_id
    zones   = ["1", "2"]
  }

  identity {
    type = var.aks_settings.identity
    identity_ids = [
      var.user_assigned_identity.id
    ] 
  }

  linux_profile {
    admin_username = var.aks_settings.admin_username
    ssh_key {
      key_data = file(var.aks_settings.ssh_key)
    }
  }

  network_profile {
    network_plugin     = var.aks_settings.network_plugin
    network_policy     = var.aks_settings.network_policy
    load_balancer_sku  = var.aks_settings.load_balancer_sku
    pod_cidr           = var.aks_settings.pod_cidr
    service_cidr       = var.aks_settings.service_cidr
    dns_service_ip     = var.aks_settings.dns_service_ip
    docker_bridge_cidr = var.aks_settings.docker_bridge_cidr
    outbound_type      = var.aks_settings.private_cluster_enabled == true ? "userDefinedRouting" : "loadBalancer"
  }
  
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  private_dns_zone_id = var.private_dns_zone_id

  # For certain services/features; requires more API request limits to CP/ARM
  sku_tier = "Paid"
  
  # role_based_access_control_enabled = false
  
  # azure_active_directory_role_based_access_control {
  #   managed = true
  #   azure_rbac_enabled = true
  #   admin_group_object_ids = var.aks_admin_group_object_ids
  # }

  lifecycle {
    ignore_changes = [
      # Incase the cluster is upgraded via an out-of-band process (i.e. Portal or AzCLI)
      kubernetes_version
    ]
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  mode                  = "User"
  node_labels           = each.value.node_labels
  vnet_subnet_id        = var.subnet_id
  node_taints           = each.value.node_taints
  zones   = ["1", "2"]
}
