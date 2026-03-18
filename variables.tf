# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for all resource names to enable multiple deployments in the same account"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 3-30 characters, lowercase alphanumeric and hyphens, starting/ending with alphanumeric."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "prevent_destroy" {
  description = "Whether to prevent destruction of critical resources (S3 buckets, KMS keys). Set to false for testing environments."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# KMS Configuration
# -----------------------------------------------------------------------------

variable "kms_deletion_window_days" {
  description = "Number of days before KMS key deletion (7-30). Use 30 for production."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_days >= 7 && var.kms_deletion_window_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

# -----------------------------------------------------------------------------
# Module Enable Toggles
# -----------------------------------------------------------------------------

variable "enable_vpc" {
  description = "Enable the VPC module"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable the CloudTrail module"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable the AWS Config module"
  type        = bool
  default     = true
}

variable "enable_iam" {
  description = "Enable the IAM baseline module"
  type        = bool
  default     = true
}

variable "enable_s3_block_public_access" {
  description = "Enable account-level S3 Block Public Access"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# VPC Variables
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_count" {
  description = "Number of public subnets to create (CIDRs will be calculated automatically)"
  type        = number
  default     = 2

  validation {
    condition     = var.public_subnet_count >= 1 && var.public_subnet_count <= 16
    error_message = "Public subnet count must be between 1 and 16."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets to create (CIDRs will be calculated automatically)"
  type        = number
  default     = 2

  validation {
    condition     = var.private_subnet_count >= 1 && var.private_subnet_count <= 16
    error_message = "Private subnet count must be between 1 and 16."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.public_subnet_cidrs) == 0 || (
      length(var.public_subnet_cidrs) >= 1 &&
      alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "Public subnet CIDRs must be valid CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.private_subnet_cidrs) == 0 || (
      length(var.private_subnet_cidrs) >= 1 &&
      alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "Private subnet CIDRs must be valid CIDR blocks."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = true
}

variable "vpc_flow_log_retention" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 90
}

# -----------------------------------------------------------------------------
# CloudTrail Variables
# -----------------------------------------------------------------------------

variable "cloudtrail_bucket_name" {
  description = "Suffix for the S3 bucket name for CloudTrail logs (will be prefixed with name_prefix)"
  type        = string
  default     = "cloudtrail-logs"
}

variable "cloudtrail_enable_kms" {
  description = "Enable KMS encryption for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_enable_cloudwatch" {
  description = "Enable CloudWatch Logs integration for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs in CloudWatch"
  type        = number
  default     = 90
}

# -----------------------------------------------------------------------------
# AWS Config Variables
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# IAM Variables
# -----------------------------------------------------------------------------

variable "iam_roles" {
  description = "List of IAM role configurations to create"
  type = list(object({
    name                = string
    description         = string
    policy_arn          = optional(string)
    inline_policy       = optional(string)
    permission_boundary = optional(string)
  }))
  default = [
    {
      name        = "ReadOnlyAdmin"
      description = "Read-only administrator role"
      policy_arn  = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    },
    {
      name        = "PowerUserRestrictedIAM"
      description = "Power user role with restricted IAM access"
      policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    },
    {
      name        = "EC2Role"
      description = "EC2 instance role for basic operations"
      policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    }
  ]
}

# -----------------------------------------------------------------------------
# GuardDuty Variables
# -----------------------------------------------------------------------------

variable "enable_guardduty" {
  description = "Enable GuardDuty threat detection"
  type        = bool
  default     = true
}

variable "guardduty_findings_bucket_name" {
  description = "Suffix for the S3 bucket name for GuardDuty findings (will be prefixed with name_prefix). Leave empty to skip findings export."
  type        = string
  default     = "guardduty-findings"
}

# -----------------------------------------------------------------------------
# Budget Variables
# -----------------------------------------------------------------------------

variable "enable_budget_alerts" {
  description = "Enable budget alerts and notifications"
  type        = bool
  default     = true
}

variable "enable_budget_actions" {
  description = "Enable budget actions for automated responses (requires at least one subscriber)"
  type        = bool
  default     = false
}

variable "budget_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 1000
}

variable "budget_alert_subscribers" {
  description = "List of email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "budget_notification_thresholds" {
  description = "List of budget threshold percentages to trigger notifications"
  type        = list(number)
  default     = [80, 100, 120, 150, 200]

  validation {
    condition     = alltrue([for t in var.budget_notification_thresholds : t > 0 && t <= 1000])
    error_message = "Budget notification thresholds must be between 1 and 1000 percent."
  }
}

# -----------------------------------------------------------------------------
# Security Hub Variables
# -----------------------------------------------------------------------------

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = false
}

variable "enable_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark standard"
  type        = bool
  default     = true
}

variable "enable_pci_standard" {
  description = "Enable PCI DSS standard"
  type        = bool
  default     = false
}

variable "enable_fsbp_standard" {
  description = "Enable AWS Foundational Security Best Practices standard"
  type        = bool
  default     = true
}

variable "enable_action_targets" {
  description = "Enable Security Hub action targets"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Macie Variables
# -----------------------------------------------------------------------------

variable "enable_macie" {
  description = "Enable Amazon Macie"
  type        = bool
  default     = false
}

variable "macie_finding_publishing_frequency" {
  description = "Frequency for publishing Macie findings"
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.macie_finding_publishing_frequency)
    error_message = "Finding publishing frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}

variable "enable_macie_s3_classification" {
  description = "Enable S3 classification job for Macie"
  type        = bool
  default     = true
}

variable "macie_s3_buckets_to_scan" {
  description = "List of S3 bucket names to scan with Macie"
  type        = list(string)
  default     = []
}

variable "macie_excluded_file_extensions" {
  description = "File extensions to exclude from Macie scanning"
  type        = list(string)
  default     = ["jpg", "jpeg", "png", "gif", "mp4", "avi", "mov"]
}

variable "macie_custom_data_identifiers" {
  description = "Map of custom data identifiers for Macie"
  type = map(object({
    description  = string
    regex        = string
    keywords     = list(string)
    ignore_words = list(string)
  }))
  default = {}
}
