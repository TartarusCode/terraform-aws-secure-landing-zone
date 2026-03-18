variable "enable_macie" {
  description = "Enable AWS Macie"
  type        = bool
  default     = false
}

variable "macie_finding_publishing_frequency" {
  description = "Frequency for publishing findings"
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.macie_finding_publishing_frequency)
    error_message = "Finding publishing frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}

variable "enable_s3_classification" {
  description = "Enable S3 classification job"
  type        = bool
  default     = true
}

variable "s3_buckets_to_scan" {
  description = "List of S3 bucket names to scan"
  type        = list(string)
  default     = []
}

variable "excluded_file_extensions" {
  description = "File extensions to exclude from scanning"
  type        = list(string)
  default     = ["jpg", "jpeg", "png", "gif", "mp4", "avi", "mov"]
}

variable "custom_data_identifiers" {
  description = "Map of custom data identifiers"
  type = map(object({
    description  = string
    regex        = string
    keywords     = list(string)
    ignore_words = list(string)
  }))
  default = {}
}

