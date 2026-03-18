variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2

  validation {
    condition     = var.public_subnet_count >= 1 && var.public_subnet_count <= 16
    error_message = "Public subnet count must be between 1 and 16."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2

  validation {
    condition     = var.private_subnet_count >= 1 && var.private_subnet_count <= 16
    error_message = "Private subnet count must be between 1 and 16."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.public_subnet_cidrs) == 0 || (
      length(var.public_subnet_cidrs) >= 1 &&
      alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "Public subnet CIDRs must be valid CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (optional, will be calculated if not provided)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.private_subnet_cidrs) == 0 || (
      length(var.private_subnet_cidrs) >= 1 &&
      alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "Private subnet CIDRs must be valid CIDR blocks."
  }
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for public subnets"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention" {
  description = "Number of days to retain VPC Flow Logs"
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "ARN of a KMS key for encrypting the CloudWatch log group"
  type        = string
  default     = ""
}
