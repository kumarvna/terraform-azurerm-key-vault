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
