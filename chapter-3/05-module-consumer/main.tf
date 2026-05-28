# ------------------------------------------------------------------------------
# 05-module-consumer — main.tf
# Consumes the webserver-cluster module from a local source path.
# The root module provides data sources and passes them into the module.
#
# Key Module Concepts Demonstrated:
#   - source = "../modules/webserver-cluster" (local path reference)
#   - Module inputs via variables
#   - Data sources in root module passed into module
#   - Module outputs consumed as module.<name>.<output>
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# DATA SOURCES — discovered in the root module, passed into the module
# ──────────────────────────────────────────────────────────────────────────────
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
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# MODULE — consumes the local webserver-cluster module
# ──────────────────────────────────────────────────────────────────────────────
module "webserver_cluster" {
  # Local path reference — Terraform resolves this relative to the root module
  source = "../modules/webserver-cluster"

  # Required variables
  cluster_name = var.cluster_name
  ami          = data.aws_ami.ubuntu.id
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = data.aws_subnets.default.ids

  # Optional variables with overrides
  instance_type = var.instance_type
  server_port   = var.server_port
  min_size      = var.min_size
  max_size      = var.max_size

  # Tags — merged with module's default tags
  tags = {
    Environment = var.environment
    Chapter     = "03-module-consumer"
    ManagedBy   = "Terraform"
  }
}
