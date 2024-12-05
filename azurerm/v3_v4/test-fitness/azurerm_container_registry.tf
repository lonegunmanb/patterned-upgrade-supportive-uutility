resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.example.location
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Premium"
  admin_enabled       = false

  encryption {
    enabled            = var.azurerm_container_registry_encryption_enabled
    identity_client_id = var.azurerm_container_registry_encryption_identity_client_id
    key_vault_key_id   = var.azurerm_container_registry_encryption_key_vault_key_id
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
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.subnet.id
    }
  }
  retention_policy {
    days = var.azurerm_container_registry_rention_in_days
  }
  trust_policy {
    enabled = var.azurerm_container_registry_trust_policy_enabled
  }
}

locals {
  retention_policy_days = azurerm_container_registry.acr[0].retention_policy[0].days
  trust_policy_enabled  = azurerm_container_registry.acr[0].trust_policy[0].enabled
}

resource "azurerm_container_registry" "dynamic_encryption" {
  location            = azurerm_resource_group.example.location
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Premium"
  admin_enabled       = false

  dynamic "encryption" {
    for_each = var.azurerm_container_registry_encryption_enabled ? ["encryption"] : []

    content {
      enabled            = var.azurerm_container_registry_encryption_enabled
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
  retention_policy {
    days = var.azurerm_container_registry_rention_in_days
  }
  trust_policy {
    enabled = var.azurerm_container_registry_trust_policy_enabled
  }
}

resource "azurerm_container_registry" "dynamic_encryption_with_custom_iterator" {
  location            = azurerm_resource_group.example.location
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Premium"
  admin_enabled       = false

  dynamic "encryption" {
    for_each = var.azurerm_container_registry_encryption_enabled ? [var.azurerm_container_registry_encryption_identity_client_id] : []
    iterator = enc

    content {
      enabled            = var.azurerm_container_registry_encryption_enabled
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
  retention_policy {
    days = var.azurerm_container_registry_rention_in_days
  }
  trust_policy {
    enabled = var.azurerm_container_registry_trust_policy_enabled
  }
}