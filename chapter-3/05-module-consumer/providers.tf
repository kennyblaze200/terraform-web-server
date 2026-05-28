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
    key            = "05-module-consumer/terraform.tfstate"
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
