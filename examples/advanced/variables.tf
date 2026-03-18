variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "my-org-adv"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []
}

variable "cloudtrail_bucket_name" {
  description = "Suffix for the S3 bucket name for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs"
}

variable "guardduty_findings_bucket_name" {
  description = "Suffix for the S3 bucket name for GuardDuty findings"
  type        = string
  default     = "guardduty-findings"
}

variable "budget_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 2000
}

variable "budget_alert_subscribers" {
  description = "List of email addresses for budget alerts"
  type        = list(string)
  default     = ["admin@example.com", "finance@example.com"]
}

variable "enable_pci_standard" {
  description = "Enable PCI DSS standard in Security Hub"
  type        = bool
  default     = false
}

variable "macie_s3_buckets_to_scan" {
  description = "List of S3 bucket names to scan with Macie"
  type        = list(string)
  default     = ["my-data-bucket", "my-backup-bucket"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment        = "advanced"
    Project            = "secure-landing-zone"
    Owner              = "platform-team"
    CostCenter         = "security"
    DataClassification = "confidential"
  }
}
