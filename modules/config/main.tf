resource "aws_iam_role" "config" {
  name = "${var.name_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-config-role"
  })
}

resource "aws_sns_topic" "config" {
  name              = "${var.name_prefix}-config-notifications"
  kms_master_key_id = var.sns_encryption_key_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-config-notifications"
  })
}

resource "aws_iam_role_policy" "config" {
  name = "${var.name_prefix}-config-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.config_bucket_name}/*"
        ]
        Condition = {
          StringLike = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.config_bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.config.arn
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.name_prefix}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.name_prefix}-config-delivery"
  s3_bucket_name = var.config_bucket_name
  s3_key_prefix  = "config"

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_config_config_rule" "managed_rules" {
  for_each = var.config_rules

  depends_on = [aws_config_configuration_recorder_status.main]

  name        = each.key
  description = "AWS Config managed rule: ${each.value}"

  source {
    owner             = "AWS"
    source_identifier = each.value
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}
