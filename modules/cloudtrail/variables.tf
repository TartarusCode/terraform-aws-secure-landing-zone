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

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "cloudtrail_enable_kms" {
  description = "Enable KMS encryption for CloudTrail"
  type        = bool
  default     = true
}

variable "s3_encryption_key_arn" {
  description = "ARN of the KMS key for S3 encryption"
  type        = string
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs integration for CloudTrail"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs in CloudWatch"
  type        = number
  default     = 90
}
