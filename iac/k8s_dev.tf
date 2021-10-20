
resource "azurerm_kubernetes_cluster" "dev" {
  name                = "nhl-dev"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = "nhl-dev"
  node_resource_group = "nhl-dev-nodes"
#  private_dns_zone_id = azurerm_dns_zone.dev.id

  default_node_pool {
    name       = "mainpool"
    enable_auto_scaling = "true"
    node_count = 2
    min_count = 2
    max_count = 4
    vm_size    = "Standard_B2s"
    os_disk_size_gb = "30"
  }

  addon_profile {
    http_application_routing {
      enabled = "true"
    }
    oms_agent {
      enabled = "true"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    }
  }

/**
  role_based_access_control {
    enabled = "false"
    enabled = "true"
    azure_active_directory {
      managed = "true"
      admin_group_object_ids = [ "c07da0e9-1e87-40d2-86c1-626cc9c0e2c4" ]
    }
  }
/**/

/**
  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }
/**/

/**/
  identity {
    type = "SystemAssigned"
  }
/**/

  tags = {
    Environment = "Developer"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool["node_count"]
    ]
  }
}

resource "azurerm_role_assignment" "acr_dev_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.dev.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

/* */
resource "azurerm_role_assignment" "k8s_dev_monitor" {
  scope                            = azurerm_kubernetes_cluster.dev.id
  role_definition_name             = "Monitoring Metrics Publisher"
  principal_id                     = azurerm_kubernetes_cluster.dev.addon_profile[0].oms_agent[0].oms_agent_identity[0].object_id
  skip_service_principal_aad_check = true
}
/* */

data "azurerm_lb" "dev" {
  name                = "kubernetes"
  resource_group_name = azurerm_kubernetes_cluster.dev.node_resource_group
}

resource "local_file" "dev_kube_config" {
 content = "${azurerm_kubernetes_cluster.dev.kube_config_raw}"
 filename = "k8s_dev_config.tfvars"
}

