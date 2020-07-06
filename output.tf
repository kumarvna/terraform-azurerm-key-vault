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

output "Key_vault_references" {
  description = "A mapping of Key Vault references for App Service and Azure Functions."
  value = {
    for k, v in azurerm_key_vault_secret.keys :
    v.name => format("@Microsoft.KeyVault(SecretUri=%s)", v.id)
  }
}
