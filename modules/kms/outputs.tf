output "s3_encryption_key_arn" {
  description = "ARN of the S3 encryption KMS key"
  value       = aws_kms_key.s3_encryption.arn
  sensitive   = true
}

output "s3_encryption_key_id" {
  description = "ID of the S3 encryption KMS key"
  value       = aws_kms_key.s3_encryption.id
  sensitive   = true
}

output "sns_encryption_key_arn" {
  description = "ARN of the SNS encryption KMS key"
  value       = aws_kms_key.sns_notifications.arn
  sensitive   = true
}

output "sns_encryption_key_id" {
  description = "ID of the SNS encryption KMS key"
  value       = aws_kms_key.sns_notifications.id
  sensitive   = true
}
