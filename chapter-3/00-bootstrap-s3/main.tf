# ------------------------------------------------------------------------------
# 00-bootstrap-s3 — main.tf
# Creates the S3 bucket and DynamoDB table required for remote state storage.
# NOTE: This project runs with LOCAL state (chicken-and-egg problem).
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# S3 BUCKET — stores Terraform state files
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Allow destruction even if bucket has versioned objects
  force_destroy = true

  tags = {
    Name        = "Terraform State Storage"
    Environment = "learning"
    Chapter     = "03-bootstrap-s3"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning so you can recover previous state versions
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for state files (contains sensitive data)
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access — state files are sensitive
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ──────────────────────────────────────────────────────────────────────────────
# DYNAMODB TABLE — state locking (prevents concurrent operations)
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Locks"
    Environment = "learning"
    Chapter     = "03-bootstrap-s3"
    ManagedBy   = "Terraform"
  }
}
