variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_roles" {
  description = "List of IAM role configurations"
  type = list(object({
    name                = string
    description         = string
    policy_arn          = optional(string)
    inline_policy       = optional(string)
    permission_boundary = optional(string)
  }))
  default = []
}

variable "create_ec2_instance_profile" {
  description = "Whether to create an EC2 instance profile"
  type        = bool
  default     = false
}

variable "ec2_instance_profile_role" {
  description = "Name of the IAM role to use for the EC2 instance profile (must be in iam_roles list)"
  type        = string
  default     = "EC2Role"
}
