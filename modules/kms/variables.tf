variable "name_prefix" {
  description = "Prefix for all resource names to enable multi-instance deployment"
  type        = string
}

variable "kms_deletion_window_days" {
  description = "Number of days before KMS key deletion (7-30)"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_days >= 7 && var.kms_deletion_window_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
