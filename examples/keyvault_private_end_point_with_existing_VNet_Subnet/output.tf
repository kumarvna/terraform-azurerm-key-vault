output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = module.key-vault.key_vault_id
}

output "key_vault_name" {
  description = "Name of key vault created."
  value       = module.key-vault.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = module.key-vault.key_vault_uri
}

output "secrets" {
  description = "A mapping of secret names and URIs."
  value       = module.key-vault.secrets
}

output "Key_vault_references" {
  description = "A mapping of Key Vault references for App Service and Azure Functions."
  value       = module.key-vault.Key_vault_references
}

output "key_vault_private_endpoint" {
  description = "The ID of the Key Vault Private Endpoint"
  value       = module.key-vault.key_vault_private_endpoint
}

output "key_vault_private_dns_zone_domain" {
  description = "DNS zone name for Key Vault Private endpoints dns name records"
  value       = module.key-vault.key_vault_private_dns_zone_domain
}

output "key_vault_private_endpoint_ip_addresses" {
  description = "Key Vault private endpoint IPv4 Addresses"
  value       = module.key-vault.key_vault_private_endpoint_ip_addresses
}

output "key_vault_private_endpoint_fqdn" {
  description = "Key Vault private endpoint FQDN Addresses"
  value       = module.key-vault.key_vault_private_endpoint_fqdn
}
