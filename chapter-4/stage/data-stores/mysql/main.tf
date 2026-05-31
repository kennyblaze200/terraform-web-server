# ------------------------------------------------------------------------------
# stage/data-stores/mysql — main.tf
# Calls the mysql module for the staging environment.
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-in-depth-state-582381606543"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-in-depth-state-locks"
    encrypt        = true
    profile        = "terraform-in-depth"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-in-depth"
}

# Data sources for networking
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# DB subnet group must be created in the caller (not the module)
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.db_name}-subnet-group"
    Environment = "staging"
  }
}

# Call the mysql module
module "mysql" {
  source = "../../../modules/data-stores/mysql"

  db_name              = var.db_name
  db_user              = var.db_user
  db_password          = var.db_password
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  engine_version       = var.engine_version
  skip_final_snapshot  = var.skip_final_snapshot
  db_subnet_group_name = aws_db_subnet_group.mysql.name

  tags = {
    Environment = "staging"
    Chapter     = "04-modules"
    ManagedBy   = "Terraform"
  }
}
