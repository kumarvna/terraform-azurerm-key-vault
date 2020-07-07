variable "log_analytics_workspace_id" {
  description = "Specifies the ID of a Log Analytics Workspace where Diagnostics Data to be sent"
  default     = null
}

variable "storage_account_id" {
  description = "The name of the storage account to store the all monitoring logs"
  default     = null
}
