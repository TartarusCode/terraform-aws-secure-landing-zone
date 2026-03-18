terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "landing_zone" {
  source = "../.."

  # Core
  name_prefix = var.name_prefix

  # VPC Configuration
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_vpc_flow_logs = true

  # CloudTrail Configuration
  cloudtrail_bucket_name       = var.cloudtrail_bucket_name
  cloudtrail_enable_kms        = true
  cloudtrail_enable_cloudwatch = true

  # AWS Config Configuration
  config_rules = {
    "s3-bucket-public-read-prohibited"  = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    "s3-bucket-public-write-prohibited" = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    "s3-bucket-ssl-requests-only"       = "S3_BUCKET_SSL_REQUESTS_ONLY"
    "s3-bucket-versioning-enabled"      = "S3_BUCKET_VERSIONING_ENABLED"
    "s3-bucket-logging-enabled"         = "S3_BUCKET_LOGGING_ENABLED"
    "iam-password-policy"               = "IAM_PASSWORD_POLICY"
    "iam-user-mfa-enabled"              = "IAM_USER_MFA_ENABLED"
    "rds-instance-public-access-check"  = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
    "rds-snapshots-public-prohibited"   = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
  }

  # IAM Configuration
  iam_roles = [
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
      name        = "SecurityAuditor"
      description = "Security auditor role"
      policy_arn  = "arn:aws:iam::aws:policy/SecurityAudit"
    }
  ]

  # GuardDuty Configuration
  enable_guardduty               = true
  guardduty_findings_bucket_name = var.guardduty_findings_bucket_name

  # Budget Configuration
  enable_budget_alerts           = true
  enable_budget_actions          = false
  budget_limit_usd               = var.budget_limit_usd
  budget_alert_subscribers       = var.budget_alert_subscribers
  budget_notification_thresholds = [50, 80, 100, 150, 200]

  # Security Hub Configuration
  enable_security_hub   = true
  enable_cis_standard   = true
  enable_pci_standard   = var.enable_pci_standard
  enable_fsbp_standard  = true
  enable_action_targets = true

  # Macie Configuration
  enable_macie                       = true
  macie_finding_publishing_frequency = "FIFTEEN_MINUTES"
  enable_macie_s3_classification     = true
  macie_s3_buckets_to_scan           = var.macie_s3_buckets_to_scan
  macie_excluded_file_extensions     = ["jpg", "jpeg", "png", "gif", "mp4", "avi", "mov", "pdf"]
  macie_custom_data_identifiers = {
    "credit_card_pattern" = {
      description  = "Credit card number pattern"
      regex        = "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b"
      keywords     = ["credit", "card", "payment"]
      ignore_words = ["test", "example", "sample"]
    },
    "ssn_pattern" = {
      description  = "Social Security Number pattern"
      regex        = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
      keywords     = ["ssn", "social", "security"]
      ignore_words = ["test", "example"]
    }
  }

  # S3 Account-Level Public Access Block
  enable_s3_block_public_access = true

  # Tags
  tags = var.tags
}
