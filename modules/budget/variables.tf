variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_budget_alerts" {
  description = "Enable budget alerts and notifications"
  type        = bool
  default     = true
}

variable "enable_budget_actions" {
  description = "Enable budget actions for automated responses (requires at least one subscriber)"
  type        = bool
  default     = false
}

variable "budget_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 1000
}

variable "budget_alert_subscribers" {
  description = "List of email addresses to receive budget alerts"
  type        = list(string)
  default     = []
}

variable "notification_thresholds" {
  description = "List of budget threshold percentages to trigger notifications"
  type        = list(number)
  default     = [80, 100, 120, 150, 200]
}

variable "sns_encryption_key_arn" {
  description = "ARN of the KMS key for SNS encryption"
  type        = string
}
