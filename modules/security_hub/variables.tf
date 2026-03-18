variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark standard"
  type        = bool
  default     = true
}

variable "enable_pci_standard" {
  description = "Enable PCI DSS standard"
  type        = bool
  default     = false
}

variable "enable_fsbp_standard" {
  description = "Enable AWS Foundational Security Best Practices standard"
  type        = bool
  default     = true
}

variable "enable_action_targets" {
  description = "Enable Security Hub action targets"
  type        = bool
  default     = true
}

