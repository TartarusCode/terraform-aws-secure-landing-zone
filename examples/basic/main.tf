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

  name_prefix            = var.name_prefix
  cloudtrail_bucket_name = var.cloudtrail_bucket_name

  tags = var.tags
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.landing_zone.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.landing_zone.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.landing_zone.private_subnet_ids
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = module.landing_zone.cloudtrail_bucket_arn
}

output "vpc_flow_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = module.landing_zone.vpc_flow_log_group_name
}
