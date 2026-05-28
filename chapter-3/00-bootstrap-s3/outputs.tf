output "state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "The ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "backend_config" {
  description = "S3 backend configuration for use in other projects"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "PLACEHOLDER/terraform.tfstate"
    region         = var.region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
  }
}
