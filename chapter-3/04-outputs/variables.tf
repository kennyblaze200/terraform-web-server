# ------------------------------------------------------------------------------
# Chapter 3 — Advanced Outputs Demo
# Variables that feed into the output demonstrations
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "learning"

  validation {
    condition     = contains(["dev", "staging", "learning", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, learning, prod."
  }
}

variable "api_key" {
  description = "A mock API key to demonstrate sensitive output handling"
  type        = string
  sensitive   = true
  default     = "sk-mock-12345-secret-key-do-not-expose"
}
