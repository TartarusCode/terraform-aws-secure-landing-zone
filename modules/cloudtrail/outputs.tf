output "bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = local.cloudtrail_bucket.arn
}

output "bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = local.cloudtrail_bucket.bucket
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail (if enabled)"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail (if enabled)"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.cloudtrail[0].arn : null
}

output "access_logs_bucket_name" {
  description = "Name of the S3 access logging bucket"
  value       = aws_s3_bucket.access_logs.bucket
}
