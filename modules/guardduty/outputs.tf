output "detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
}

output "publishing_destination_arn" {
  description = "ARN of the GuardDuty publishing destination"
  value       = local.create_bucket ? aws_guardduty_publishing_destination.main[0].destination_arn : null
}

output "findings_bucket_arn" {
  description = "ARN of the GuardDuty findings S3 bucket"
  value       = local.create_bucket ? local.guardduty_bucket.arn : null
}

output "findings_bucket_name" {
  description = "Name of the GuardDuty findings S3 bucket"
  value       = local.create_bucket ? local.guardduty_bucket.bucket : null
}
