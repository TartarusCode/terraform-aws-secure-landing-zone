variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "config_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs"
  type        = string
}

variable "config_rules" {
  description = "Map of AWS Config rule names to managed rule source identifiers"
  type        = map(string)
  default = {
    "s3-bucket-public-read-prohibited"  = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    "s3-bucket-public-write-prohibited" = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    "s3-bucket-ssl-requests-only"       = "S3_BUCKET_SSL_REQUESTS_ONLY"
    "s3-bucket-versioning-enabled"      = "S3_BUCKET_VERSIONING_ENABLED"
    "s3-bucket-logging-enabled"         = "S3_BUCKET_LOGGING_ENABLED"
  }
}

variable "sns_encryption_key_arn" {
  description = "ARN of the KMS key for SNS encryption"
  type        = string
}
