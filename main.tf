terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# KMS Module
module "kms" {
  source = "./modules/kms"

  name_prefix              = var.name_prefix
  kms_deletion_window_days = var.kms_deletion_window_days
  tags                     = var.tags
}

# S3 Account-Level Public Access Block
resource "aws_s3_account_public_access_block" "main" {
  count = var.enable_s3_block_public_access ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# VPC Module
module "vpc" {
  count  = var.enable_vpc ? 1 : 0
  source = "./modules/vpc"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_flow_logs     = var.enable_vpc_flow_logs
  flow_log_retention   = var.vpc_flow_log_retention
  kms_key_arn          = module.kms.s3_encryption_key_arn
  tags                 = var.tags
}

# CloudTrail Module
module "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  source = "./modules/cloudtrail"

  name_prefix            = var.name_prefix
  cloudtrail_bucket_name = "${var.name_prefix}-${var.cloudtrail_bucket_name}"
  cloudtrail_enable_kms  = var.cloudtrail_enable_kms
  s3_encryption_key_arn  = module.kms.s3_encryption_key_arn
  enable_cloudwatch_logs = var.cloudtrail_enable_cloudwatch
  log_retention_days     = var.cloudtrail_log_retention_days
  prevent_destroy        = var.prevent_destroy
  tags                   = var.tags
}

# AWS Config Module
module "config" {
  count  = var.enable_config ? 1 : 0
  source = "./modules/config"

  name_prefix            = var.name_prefix
  config_bucket_name     = "${var.name_prefix}-${var.cloudtrail_bucket_name}"
  config_rules           = var.config_rules
  sns_encryption_key_arn = module.kms.sns_encryption_key_arn
  tags                   = var.tags
}

# IAM Module
module "iam" {
  count  = var.enable_iam ? 1 : 0
  source = "./modules/iam"

  name_prefix = var.name_prefix
  iam_roles   = var.iam_roles
  tags        = var.tags
}

# GuardDuty Module
module "guardduty" {
  source = "./modules/guardduty"

  name_prefix                    = var.name_prefix
  enable_guardduty               = var.enable_guardduty
  guardduty_findings_bucket_name = var.guardduty_findings_bucket_name != "" ? "${var.name_prefix}-${var.guardduty_findings_bucket_name}" : ""
  s3_encryption_key_arn          = module.kms.s3_encryption_key_arn
  prevent_destroy                = var.prevent_destroy
  tags                           = var.tags
}

# Budget Module
module "budget" {
  source = "./modules/budget"

  name_prefix              = var.name_prefix
  enable_budget_alerts     = var.enable_budget_alerts
  enable_budget_actions    = var.enable_budget_actions
  budget_limit_usd         = var.budget_limit_usd
  budget_alert_subscribers = var.budget_alert_subscribers
  notification_thresholds  = var.budget_notification_thresholds
  sns_encryption_key_arn   = module.kms.sns_encryption_key_arn
  tags                     = var.tags
}

# Security Hub Module
module "security_hub" {
  source = "./modules/security_hub"

  enable_security_hub   = var.enable_security_hub
  enable_cis_standard   = var.enable_cis_standard
  enable_pci_standard   = var.enable_pci_standard
  enable_fsbp_standard  = var.enable_fsbp_standard
  enable_action_targets = var.enable_action_targets
}

# Macie Module
module "macie" {
  source = "./modules/macie"

  enable_macie                       = var.enable_macie
  macie_finding_publishing_frequency = var.macie_finding_publishing_frequency
  enable_s3_classification           = var.enable_macie_s3_classification
  s3_buckets_to_scan                 = var.macie_s3_buckets_to_scan
  excluded_file_extensions           = var.macie_excluded_file_extensions
  custom_data_identifiers            = var.macie_custom_data_identifiers
}
