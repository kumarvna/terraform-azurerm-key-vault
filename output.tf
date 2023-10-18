output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of key vault created."
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.main.vault_uri
}

output "secrets" {
  description = "A mapping of secret names and URIs."
  value       = { for k, v in azurerm_key_vault_secret.keys : v.name => v.id }
}

output "versionless_resource_secrets" {
  description = "A mapping of secret names and and versionless resource IDs."
  value       = { for k, v in azurerm_key_vault_secret.keys : v.name => v.resource_versionless_id }
}

output "key_vault_references" {
  description = "A mapping of Key Vault references for App Service and Azure Functions."
  value = {
    for k, v in azurerm_key_vault_secret.keys :
    v.name => format("@Microsoft.KeyVault(SecretUri=%s)", v.id)
  }
}

output "key_vault_private_endpoint" {
  description = "The ID of the Key Vault Private Endpoint"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_endpoint.pep1.*.id, [""]), 0) : null
}

output "key_vault_private_dns_zone_domain" {
  description = "DNS zone name for Key Vault Private endpoints dns name records"
  value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? element(concat(azurerm_private_dns_zone.dnszone1.*.name, [""]), 0) : var.existing_private_dns_zone
}

output "key_vault_private_endpoint_ip_addresses" {
  description = "Key Vault private endpoint IPv4 Addresses"
  value       = var.enable_private_endpoint ? flatten(azurerm_private_endpoint.pep1.0.custom_dns_configs.*.ip_addresses) : null
}

output "key_vault_private_endpoint_fqdn" {
  description = "Key Vault private endpoint FQDN Addresses"
  value       = var.enable_private_endpoint ? flatten(azurerm_private_endpoint.pep1.0.custom_dns_configs.*.fqdn) : null
}
