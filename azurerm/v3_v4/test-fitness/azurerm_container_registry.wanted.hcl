resource "azurerm_container_registry" "acr" {
  location                 = azurerm_resource_group.example.location
  name                     = "containerRegistry1"
  resource_group_name      = azurerm_resource_group.example.name
  sku                      = "Premium"
  admin_enabled            = false
  retention_policy_in_days = var.azurerm_container_registry_rention_in_days
  trust_policy_enabled     = var.azurerm_container_registry_trust_policy_enabled

  dynamic "encryption" {
    for_each = (var.azurerm_container_registry_encryption_enabled) ? ["encryption"] : []
    iterator = encryption

    content {
      identity_client_id = var.azurerm_container_registry_encryption_identity_client_id
      key_vault_key_id   = var.azurerm_container_registry_encryption_key_vault_key_id
    }
  }
  georeplications {
    location                = "East US"
    tags                    = {}
    zone_redundancy_enabled = true
  }
  georeplications {
    location                = "North Europe"
    tags                    = {}
    zone_redundancy_enabled = true
  }
  network_rule_set {
    default_action = "Allow"
  }
}

locals {
  retention_policy_days = azurerm_container_registry.acr[0].retention_policy_in_days
  trust_policy_enabled  = azurerm_container_registry.acr[0].trust_policy_enabled
}

resource "azurerm_container_registry" "dynamic_encryption" {
  location                 = azurerm_resource_group.example.location
  name                     = "containerRegistry1"
  resource_group_name      = azurerm_resource_group.example.name
  sku                      = "Premium"
  admin_enabled            = false
  retention_policy_in_days = var.azurerm_container_registry_rention_in_days
  trust_policy_enabled     = var.azurerm_container_registry_trust_policy_enabled

  dynamic "encryption" {
    for_each = try((var.azurerm_container_registry_encryption_enabled) ? { for k, v in(var.azurerm_container_registry_encryption_enabled ? ["encryption"] : []) : k => v } : tomap({}), (var.azurerm_container_registry_encryption_enabled) ? (var.azurerm_container_registry_encryption_enabled ? ["encryption"] : []) : toset([]))
    iterator = encryption

    content {
      identity_client_id = var.azurerm_container_registry_encryption_identity_client_id
      key_vault_key_id   = var.azurerm_container_registry_encryption_key_vault_key_id
    }
  }
  georeplications {
    location                = "East US"
    tags                    = {}
    zone_redundancy_enabled = true
  }
  georeplications {
    location                = "North Europe"
    tags                    = {}
    zone_redundancy_enabled = true
  }
}

resource "azurerm_container_registry" "dynamic_encryption_with_custom_iterator" {
  location                 = azurerm_resource_group.example.location
  name                     = "containerRegistry1"
  resource_group_name      = azurerm_resource_group.example.name
  sku                      = "Premium"
  admin_enabled            = false
  retention_policy_in_days = var.azurerm_container_registry_rention_in_days
  trust_policy_enabled     = var.azurerm_container_registry_trust_policy_enabled

  dynamic "encryption" {
    for_each = try((var.azurerm_container_registry_encryption_enabled) ? { for k, v in(var.azurerm_container_registry_encryption_enabled ? [var.azurerm_container_registry_encryption_identity_client_id] : []) : k => v } : tomap({}), (var.azurerm_container_registry_encryption_enabled) ? (var.azurerm_container_registry_encryption_enabled ? [var.azurerm_container_registry_encryption_identity_client_id] : []) : toset([]))
    iterator = enc

    content {
      identity_client_id = enc.value
      key_vault_key_id   = var.azurerm_container_registry_encryption_key_vault_key_id
    }
  }
  georeplications {
    location                = "East US"
    tags                    = {}
    zone_redundancy_enabled = true
  }
  georeplications {
    location                = "North Europe"
    tags                    = {}
    zone_redundancy_enabled = true
  }
}