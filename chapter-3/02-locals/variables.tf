# ------------------------------------------------------------------------------
# Chapter 3 — Local Values Demo
# Variables that feed into local computations
# ------------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "learning"

  validation {
    condition     = contains(["dev", "staging", "learning", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, learning, prod."
  }
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "terraform-in-depth"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "custom_ami_id" {
  description = "Custom AMI ID. If null, the latest Ubuntu 22.04 will be looked up via data source."
  type        = string
  default     = null
  nullable    = true
}

variable "base_tags" {
  description = "Base tags applied to all resources (merged with computed tags)"
  type        = map(string)
  default = {
    Project     = "terraform-in-depth"
    Repository  = "terraform-aws-modules"
    ManagedBy   = "Terraform"
  }
}

variable "enable_backup" {
  description = "Whether to enable automated backups"
  type        = bool
  default     = false
}
