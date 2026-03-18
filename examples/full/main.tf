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
  cloudtrail_enable_kms        = var.cloudtrail_enable_kms
  cloudtrail_enable_cloudwatch = true

  # AWS Config Configuration
  config_rules = var.config_rules

  # IAM Configuration
  iam_roles = var.iam_roles

  # GuardDuty Configuration
  enable_guardduty               = var.enable_guardduty
  guardduty_findings_bucket_name = var.guardduty_findings_bucket_name

  # Budget Configuration
  enable_budget_alerts     = var.enable_budget_alerts
  enable_budget_actions    = var.enable_budget_actions
  budget_limit_usd         = var.budget_limit_usd
  budget_alert_subscribers = var.budget_alert_subscribers

  # S3 Account-Level Public Access Block
  enable_s3_block_public_access = true

  # Tags
  tags = var.tags
}
