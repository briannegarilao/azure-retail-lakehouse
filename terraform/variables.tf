variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastasia"
}

variable "resource_group_name" {
  description = "Main project resource group."
  type        = string
}

variable "storage_account_name" {
  description = "ADLS Gen2 storage account name."
  type        = string
}

variable "data_factory_name" {
  description = "Azure Data Factory name."
  type        = string
}

variable "databricks_workspace_name" {
  description = "Azure Databricks workspace name."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}