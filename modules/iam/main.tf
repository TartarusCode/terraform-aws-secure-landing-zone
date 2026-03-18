terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  roles_map = { for role in var.iam_roles : role.name => role }
}

resource "aws_iam_role" "roles" {
  for_each = local.roles_map

  name        = "${var.name_prefix}-${each.value.name}"
  description = each.value.description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  permissions_boundary = each.value.permission_boundary

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value.name}"
  })
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = {
    for role in var.iam_roles : role.name => role
    if role.policy_arn != null
  }

  role       = aws_iam_role.roles[each.key].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "inline_policies" {
  for_each = {
    for role in var.iam_roles : role.name => role
    if role.inline_policy != null
  }

  name   = "${var.name_prefix}-${each.key}-inline-policy"
  role   = aws_iam_role.roles[each.key].id
  policy = each.value.inline_policy
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_ec2_instance_profile && contains(keys(local.roles_map), var.ec2_instance_profile_role) ? 1 : 0
  name  = "${var.name_prefix}-ec2-profile"
  role  = aws_iam_role.roles[var.ec2_instance_profile_role].name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-profile"
  })
}
