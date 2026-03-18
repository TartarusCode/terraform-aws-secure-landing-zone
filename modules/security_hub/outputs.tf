output "security_hub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = var.enable_security_hub
}

output "cis_standard_enabled" {
  description = "Whether CIS AWS Foundations Benchmark standard is enabled"
  value       = var.enable_security_hub && var.enable_cis_standard
}

output "pci_standard_enabled" {
  description = "Whether PCI DSS standard is enabled"
  value       = var.enable_security_hub && var.enable_pci_standard
}

output "fsbp_standard_enabled" {
  description = "Whether AWS Foundational Security Best Practices standard is enabled"
  value       = var.enable_security_hub && var.enable_fsbp_standard
}

output "action_targets_enabled" {
  description = "Whether Security Hub action targets are enabled"
  value       = var.enable_security_hub && var.enable_action_targets
}

output "insights_created" {
  description = "Number of Security Hub insights created"
  value       = var.enable_security_hub ? 2 : 0
}
