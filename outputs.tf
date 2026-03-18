# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_ids : []
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_cidr_block : null
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = var.enable_vpc ? module.vpc[0].internet_gateway_id : null
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = var.enable_vpc ? module.vpc[0].nat_gateway_id : null
}

output "vpc_flow_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_vpc && var.enable_vpc_flow_logs ? module.vpc[0].flow_log_group_name : null
}

# -----------------------------------------------------------------------------
# CloudTrail Outputs
# -----------------------------------------------------------------------------

output "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = var.enable_cloudtrail ? module.cloudtrail[0].bucket_arn : null
}

output "cloudtrail_bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = var.enable_cloudtrail ? module.cloudtrail[0].bucket_name : null
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? module.cloudtrail[0].cloudtrail_arn : null
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption (if enabled)"
  value       = var.cloudtrail_enable_kms ? module.kms.s3_encryption_key_arn : null
  sensitive   = true
}

output "cloudtrail_cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for CloudTrail (if enabled)"
  value       = var.enable_cloudtrail && var.cloudtrail_enable_cloudwatch ? module.cloudtrail[0].cloudwatch_log_group_name : null
}

# -----------------------------------------------------------------------------
# AWS Config Outputs
# -----------------------------------------------------------------------------

output "config_rule_arns" {
  description = "Map of Config rule names to ARNs"
  value       = var.enable_config ? module.config[0].rule_arns : {}
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = var.enable_config ? module.config[0].recorder_name : null
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "iam_role_arns" {
  description = "Map of IAM role names to ARNs"
  value       = var.enable_iam ? module.iam[0].role_arns : {}
}

output "iam_role_names" {
  description = "List of IAM role names"
  value       = var.enable_iam ? module.iam[0].role_names : []
}

# -----------------------------------------------------------------------------
# GuardDuty Outputs
# -----------------------------------------------------------------------------

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = module.guardduty.detector_id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = module.guardduty.detector_arn
}

output "guardduty_findings_bucket_arn" {
  description = "ARN of the GuardDuty findings S3 bucket"
  value       = module.guardduty.findings_bucket_arn
}

# -----------------------------------------------------------------------------
# Budget Outputs
# -----------------------------------------------------------------------------

output "budget_id" {
  description = "ID of the cost budget"
  value       = module.budget.budget_id
}

output "budget_arn" {
  description = "ARN of the cost budget"
  value       = module.budget.budget_arn
}

output "budget_sns_topic_arn" {
  description = "ARN of the SNS topic for budget alerts"
  value       = module.budget.sns_topic_arn
}

# -----------------------------------------------------------------------------
# Security Hub Outputs
# -----------------------------------------------------------------------------

output "security_hub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = module.security_hub.security_hub_enabled
}

output "cis_standard_enabled" {
  description = "Whether CIS AWS Foundations Benchmark standard is enabled"
  value       = module.security_hub.cis_standard_enabled
}

output "pci_standard_enabled" {
  description = "Whether PCI DSS standard is enabled"
  value       = module.security_hub.pci_standard_enabled
}

output "fsbp_standard_enabled" {
  description = "Whether AWS Foundational Security Best Practices standard is enabled"
  value       = module.security_hub.fsbp_standard_enabled
}

output "security_hub_action_targets_enabled" {
  description = "Whether Security Hub action targets are enabled"
  value       = module.security_hub.action_targets_enabled
}

output "security_hub_insights_created" {
  description = "Number of Security Hub insights created"
  value       = module.security_hub.insights_created
}

# -----------------------------------------------------------------------------
# Macie Outputs
# -----------------------------------------------------------------------------

output "macie_enabled" {
  description = "Whether Macie is enabled"
  value       = module.macie.macie_enabled
}

output "macie_classification_job_enabled" {
  description = "Whether S3 classification job is enabled"
  value       = module.macie.classification_job_enabled
}

output "macie_custom_identifiers_count" {
  description = "Number of custom data identifiers created"
  value       = module.macie.custom_identifiers_count
}

output "macie_buckets_to_scan_count" {
  description = "Number of S3 buckets configured for scanning"
  value       = module.macie.buckets_to_scan_count
}

# -----------------------------------------------------------------------------
# S3 Account-Level Outputs
# -----------------------------------------------------------------------------

output "s3_block_public_access_enabled" {
  description = "Whether account-level S3 Block Public Access is enabled"
  value       = var.enable_s3_block_public_access
}

# -----------------------------------------------------------------------------
# Shared KMS Key Outputs
# -----------------------------------------------------------------------------

output "s3_encryption_key_arn" {
  description = "ARN of the shared S3 encryption KMS key"
  value       = module.kms.s3_encryption_key_arn
  sensitive   = true
}

output "s3_encryption_key_id" {
  description = "ID of the shared S3 encryption KMS key"
  value       = module.kms.s3_encryption_key_id
  sensitive   = true
}

output "sns_encryption_key_arn" {
  description = "ARN of the shared SNS encryption KMS key"
  value       = module.kms.sns_encryption_key_arn
  sensitive   = true
}

output "sns_encryption_key_id" {
  description = "ID of the shared SNS encryption KMS key"
  value       = module.kms.sns_encryption_key_id
  sensitive   = true
}
