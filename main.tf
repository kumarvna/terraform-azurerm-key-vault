
locals {
  access_policies = [
    for p in var.access_policies : merge({
      azure_ad_group_names          = []
      object_ids                    = []
      azure_ad_user_principal_names = []
      certificate_permissions       = []
      key_permissions               = []
      secret_permissions            = []
      storage_permissions           = []
    }, p)
  ]

  azure_ad_group_names          = distinct(flatten(local.access_policies[*].azure_ad_group_names))
  azure_ad_user_principal_names = distinct(flatten(local.access_policies[*].azure_ad_user_principal_names))

  group_object_ids = { for g in data.azuread_group.adgrp : lower(g.name) => g.id }
  user_object_ids  = { for u in data.azuread_user.adusr : lower(u.user_principal_name) => u.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }

  combined_access_policies = [
    for k, v in local.grouped_access_policies : {
      object_id               = k
      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
      key_permissions         = distinct(flatten(v[*].key_permissions))
      secret_permissions      = distinct(flatten(v[*].secret_permissions))
      storage_permissions     = distinct(flatten(v[*].storage_permissions))
    }
  ]

  service_principal_object_id = data.azurerm_client_config.current.object_id

  self_permissions = {
    object_id               = local.service_principal_object_id
    tenant_id               = data.azurerm_client_config.current.tenant_id
    key_permissions         = ["create", "delete", "get", "backup", "decrypt", "encrypt", "import", "list", "purge", "recover", "restore", "sign", "update", "verify"]
    secret_permissions      = ["backup", "delete", "get", "list", "purge", "recover", "restore", "set"]
    certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update"]
    storage_permissions     = ["backup", "delete", "deletesas", "get", "getsas", "list", "listsas", "purge", "recover", "regeneratekey", "restore", "set", "setsas", "update"]
  }
}

data "azuread_group" "adgrp" {
  count        = length(local.azure_ad_group_names)
  display_name = local.azure_ad_group_names[count.index]
}

data "azuread_user" "adusr" {
  count               = length(local.azure_ad_user_principal_names)
  user_principal_name = local.azure_ad_user_principal_names[count.index]
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                            = lower("kv-${var.key_vault_name}")
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.enable_purge_protection
  tags                            = merge({ "ResourceName" = lower("kv-${var.key_vault_name}") }, var.tags, )

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "access_policy" {
    for_each = local.combined_access_policies
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
  dynamic "access_policy" {
    for_each = local.service_principal_object_id != "" ? [local.self_permissions] : []
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
}

resource "random_password" "passwd" {
  for_each    = { for k, v in var.secrets : k => v if v == "" }
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  min_special = 4

  keepers = {
    name = each.key
  }
}

resource "azurerm_key_vault_secret" "keys" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                          = var.log_analytics_workspace_id != null ? 1 : 0
  name                           = format("%s-analytics", azurerm_key_vault.main.name)
  target_resource_id             = azurerm_key_vault.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"
  storage_account_id             = var.storage_account_id != null ? var.storage_account_id : null
  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}
