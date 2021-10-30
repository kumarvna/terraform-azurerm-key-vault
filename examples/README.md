# Azure Key Vault Terraform Module

Terraform Module to create a Key Vault also adds required access policies for azure AD users, groups and azure AD service principals. This module also creates private endpoint and sends all logs to log analytic workspace or storage.

## Module Usage for

* [Simple Key Vault Creation](simple_keyvault/)
* [Key Vault with Private Endpoint](keyvault_with_private_end_point/)
* [Key Vault with Private Endpoiont using existing VNet and Subnet](keyvault_private_end_point_with_existing_VNet_Subnet/)

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.
