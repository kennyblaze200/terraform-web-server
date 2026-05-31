# ------------------------------------------------------------------------------
# prod/services/webserver-cluster — main.tf
# Calls the webserver-cluster module for the production environment.
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
    key            = "prod/services/webserver-cluster/terraform.tfstate"
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

# Data sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Call the webserver-cluster module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name  = var.cluster_name
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  server_port   = var.server_port
  min_size      = var.min_size
  max_size      = var.max_size
  vpc_id        = data.aws_vpc.default.id
  subnet_ids    = data.aws_subnets.default.ids

  tags = {
    Environment = "production"
    Chapter     = "04-modules"
    ManagedBy   = "Terraform"
  }
}
