locals {
  has_subscribers  = length(var.budget_alert_subscribers) > 0
  enable_actions   = var.enable_budget_alerts && var.enable_budget_actions && local.has_subscribers
  notification_set = local.has_subscribers ? var.notification_thresholds : []
}

# -----------------------------------------------------------------------------
# SNS Topic for Budget Notifications
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "budget" {
  count = var.enable_budget_alerts ? 1 : 0

  name              = "${var.name_prefix}-budget-alerts"
  kms_master_key_id = var.sns_encryption_key_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-budget-alerts"
  })
}

resource "aws_sns_topic_policy" "budget" {
  count = var.enable_budget_alerts ? 1 : 0

  arn = aws_sns_topic.budget[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.budget[0].arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "budget" {
  for_each = var.enable_budget_alerts ? toset(var.budget_alert_subscribers) : toset([])

  topic_arn = aws_sns_topic.budget[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# -----------------------------------------------------------------------------
# Budget
# -----------------------------------------------------------------------------

resource "aws_budgets_budget" "cost" {
  count = var.enable_budget_alerts ? 1 : 0

  name         = "${var.name_prefix}-cost-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"

  dynamic "notification" {
    for_each = local.notification_set
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.budget_alert_subscribers
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cost-budget"
  })
}

# -----------------------------------------------------------------------------
# Budget Action (optional automated response)
# -----------------------------------------------------------------------------

resource "aws_budgets_budget_action" "cost_control" {
  count = local.enable_actions ? 1 : 0

  budget_name        = aws_budgets_budget.cost[0].name
  action_type        = "APPLY_IAM_POLICY"
  approval_model     = "AUTOMATIC"
  execution_role_arn = aws_iam_role.budget_action[0].arn
  notification_type  = "ACTUAL"

  action_threshold {
    action_threshold_type  = "PERCENTAGE"
    action_threshold_value = 200
  }

  definition {
    iam_action_definition {
      policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
    }
  }

  subscriber {
    address           = var.budget_alert_subscribers[0]
    subscription_type = "EMAIL"
  }
}

resource "aws_iam_role" "budget_action" {
  count = local.enable_actions ? 1 : 0

  name = "${var.name_prefix}-budget-action-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-budget-action-role"
  })
}

resource "aws_iam_role_policy" "budget_action" {
  count = local.enable_actions ? 1 : 0

  name = "${var.name_prefix}-budget-action-policy"
  role = aws_iam_role.budget_action[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BudgetActionApplyPolicy"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/${var.name_prefix}-*"
        Condition = {
          ArnEquals = {
            "iam:PolicyARN" = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
          }
        }
      }
    ]
  })
}
