# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.landing_zone.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.landing_zone.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.landing_zone.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.landing_zone.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.landing_zone.internet_gateway_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.landing_zone.nat_gateway_id
}

output "vpc_flow_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = module.landing_zone.vpc_flow_log_group_name
}

# CloudTrail Outputs
output "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = module.landing_zone.cloudtrail_bucket_arn
}

output "cloudtrail_bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = module.landing_zone.cloudtrail_bucket_name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = module.landing_zone.cloudtrail_arn
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption"
  value       = module.landing_zone.cloudtrail_kms_key_arn
  sensitive   = true
}

output "cloudtrail_cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = module.landing_zone.cloudtrail_cloudwatch_log_group
}

# AWS Config Outputs
output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = module.landing_zone.config_recorder_name
}

output "config_rule_arns" {
  description = "Map of Config rule names to ARNs"
  value       = module.landing_zone.config_rule_arns
}

# IAM Outputs
output "iam_role_arns" {
  description = "Map of IAM role names to ARNs"
  value       = module.landing_zone.iam_role_arns
}

output "iam_role_names" {
  description = "List of IAM role names"
  value       = module.landing_zone.iam_role_names
}

# GuardDuty Outputs
output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = module.landing_zone.guardduty_detector_id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = module.landing_zone.guardduty_detector_arn
}

output "guardduty_findings_bucket_arn" {
  description = "ARN of the GuardDuty findings S3 bucket"
  value       = module.landing_zone.guardduty_findings_bucket_arn
}

# Budget Outputs
output "budget_id" {
  description = "ID of the cost budget"
  value       = module.landing_zone.budget_id
}

output "budget_arn" {
  description = "ARN of the cost budget"
  value       = module.landing_zone.budget_arn
}

output "budget_sns_topic_arn" {
  description = "ARN of the SNS topic for budget alerts"
  value       = module.landing_zone.budget_sns_topic_arn
}

# S3 Account-Level Outputs
output "s3_block_public_access_enabled" {
  description = "Whether account-level S3 Block Public Access is enabled"
  value       = module.landing_zone.s3_block_public_access_enabled
}
