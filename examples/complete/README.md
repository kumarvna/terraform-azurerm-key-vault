# Azure Key Vault Terraform Module

Terraform Module to create a Key Vault also adds required access policies for AD users and groups. This module also sends all logs to log analytic workspace and storage.

## Module Usage

```hcl
module "key-vault" {
  source  = "kumarvna/key-vault/azurerm"
  version = "2.0.0"

  # Resource Group and Key Vault pricing tier details
  resource_group_name        = "rg-demo-project-shared-westeurope-001"
  key_vault_name             = "demo-project-shard"
  key_vault_sku_pricing_tier = "premium"

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted (currently 90 days)
  # Once `Soft Delete` has been Enabled it's not possible to Disable it.
  enable_purge_protection = false
  enable_soft_delete      = false

  # Adding Key valut logs to Azure monitoring and Log Analytics space
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id

  # Access policies for users, you can provide list of Azure AD users and set permissions.
  # Make sure to use list of user principal names of Azure AD users.
  access_policies = [
    {
      azure_ad_user_principal_names = ["user1@example.com", "user2@example.com"]
      key_permissions               = ["get", "list"]
      secret_permissions            = ["get", "list"]
      certificate_permissions       = ["get", "import", "list"]
      storage_permissions           = ["backup", "get", "list", "recover"]
    },

    # Access policies for AD Groups, enable this feature to provide list of Azure AD groups and set permissions.
    {
      azure_ad_group_names = ["ADGroupName1", "ADGroupName2"]
      secret_permissions   = ["get", "list", "set"]
    },
  ]

  # Create a required Secrets as per your need.
  # When you Add `usernames` with empty password this module creates a strong random password
  # use .tfvars file to manage the secrets to avoid security violations.
  secrets = {
    "message" = "Hello, world!"
    "vmpass"  = ""
  }

  # Adding TAG's to your Azure resources (Required)
  # ProjectName and Env are already declared above, to use them here or create a varible.
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
```

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init

terraform plan

terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Outputs

Name | Description
---- | -----------
`key_vault_id`|The ID of the Key Vault
`key_vault_name`|Name of key vault created
`key_vault_uri`|The URI of the Key Vault, used for performing operations on keys and secrets
`secrets`|A mapping of secret names and URIs
`Key_vault_references`|A mapping of Key Vault references for App Service and Azure Functions
