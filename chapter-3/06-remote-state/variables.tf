# ------------------------------------------------------------------------------
# 06-remote-state — Variables
# Configures the S3 backend of the source project to read from
# ------------------------------------------------------------------------------

variable "remote_state_bucket" {
  description = "The S3 bucket where the source project stores its state"
  type        = string
}

variable "remote_state_key" {
  description = "The S3 key (path) of the source project's state file"
  type        = string
  default     = "terraform-module-demo/terraform.tfstate"
}

variable "remote_state_region" {
  description = "The AWS region of the S3 state bucket"
  type        = string
  default     = "us-east-1"
}
