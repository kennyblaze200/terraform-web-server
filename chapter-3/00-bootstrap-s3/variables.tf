variable "state_bucket_name" {
  description = "Globally unique name for the S3 state bucket"
  type        = string
  default     = "terraform-in-depth-state-582381606543"
}

variable "lock_table_name" {
  description = "Name for the DynamoDB state locking table"
  type        = string
  default     = "terraform-in-depth-state-locks"
}

variable "region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "us-east-1"
}
