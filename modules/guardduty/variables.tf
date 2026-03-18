variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "prevent_destroy" {
  description = "Whether to prevent destruction of critical resources (S3 buckets). Set to false for testing environments."
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable GuardDuty detector"
  type        = bool
  default     = true
}

variable "guardduty_findings_bucket_name" {
  description = "Name of the S3 bucket for GuardDuty findings. Leave empty to skip findings export."
  type        = string
  default     = ""
}

variable "s3_encryption_key_arn" {
  description = "ARN of the KMS key for S3 encryption"
  type        = string
}
