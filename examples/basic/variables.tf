variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "my-org-dev"
}

variable "cloudtrail_bucket_name" {
  description = "Suffix for the S3 bucket name for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Owner       = "platform-team"
    Project     = "landing-zone"
  }
}
