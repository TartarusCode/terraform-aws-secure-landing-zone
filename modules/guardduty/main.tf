data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  region        = data.aws_region.current.region
  create_bucket = var.enable_guardduty && var.guardduty_findings_bucket_name != ""
  guardduty_bucket = local.create_bucket ? (
    var.prevent_destroy ? aws_s3_bucket.guardduty_findings_protected[0] : aws_s3_bucket.guardduty_findings_unprotected[0]
  ) : null
}

# -----------------------------------------------------------------------------
# GuardDuty Detector
# -----------------------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty-detector"
  })
}

resource "aws_guardduty_detector_feature" "s3_logs" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.main[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "malware_protection" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.main[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

# -----------------------------------------------------------------------------
# S3 Access Logging Bucket for GuardDuty Findings
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = "${var.guardduty_findings_bucket_name}-access-logs"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty-access-logs"
  })
}

resource "aws_s3_bucket_public_access_block" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.guardduty_access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.guardduty_access_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.guardduty_access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_encryption_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.guardduty_access_logs[0].id

  rule {
    id     = "access-log-lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "guardduty_access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.guardduty_access_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.guardduty_access_logs[0].arn,
          "${aws_s3_bucket.guardduty_access_logs[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "S3ServerAccessLogsPolicy"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.guardduty_access_logs[0].arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.guardduty_findings_bucket_name}"
          }
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# GuardDuty Findings S3 Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "guardduty_findings_protected" {
  count  = local.create_bucket && var.prevent_destroy ? 1 : 0
  bucket = var.guardduty_findings_bucket_name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty-findings"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "guardduty_findings_unprotected" {
  count  = local.create_bucket && !var.prevent_destroy ? 1 : 0
  bucket = var.guardduty_findings_bucket_name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty-findings"
  })
}

resource "aws_s3_bucket_versioning" "guardduty_findings" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.guardduty_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_findings" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.guardduty_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_encryption_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "guardduty_findings" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.guardduty_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "guardduty_findings" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.guardduty_bucket.id

  target_bucket = aws_s3_bucket.guardduty_access_logs[0].id
  target_prefix = "guardduty-bucket-logs/"
}

resource "aws_s3_bucket_policy" "guardduty_findings" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.guardduty_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          local.guardduty_bucket.arn,
          "${local.guardduty_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AWSGuardDutyAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = local.guardduty_bucket.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:guardduty:${local.region}:${local.account_id}:detector/*"
          }
        }
      },
      {
        Sid    = "AWSGuardDutyLocation"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetBucketLocation"
        Resource = local.guardduty_bucket.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:guardduty:${local.region}:${local.account_id}:detector/*"
          }
        }
      },
      {
        Sid    = "AWSGuardDutyWrite"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${local.guardduty_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:guardduty:${local.region}:${local.account_id}:detector/*"
          }
        }
      }
    ]
  })
}

resource "aws_guardduty_publishing_destination" "main" {
  count = local.create_bucket ? 1 : 0

  detector_id      = aws_guardduty_detector.main[0].id
  destination_type = "S3"
  destination_arn  = local.guardduty_bucket.arn
  kms_key_arn      = var.s3_encryption_key_arn

  depends_on = [aws_s3_bucket_policy.guardduty_findings]
}
