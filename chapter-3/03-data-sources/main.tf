# ------------------------------------------------------------------------------
# 03-data-sources — main.tf
# Demonstrates a variety of AWS data sources for querying existing
# infrastructure and account metadata.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# 1. AWS Account Identity — get current account ID, user ARN, user ID
# ──────────────────────────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}

# ──────────────────────────────────────────────────────────────────────────────
# 2. AWS Region — get current region name and description
# ──────────────────────────────────────────────────────────────────────────────
data "aws_region" "current" {}

# ──────────────────────────────────────────────────────────────────────────────
# 3. Availability Zones — list all AZs in the current region
# ──────────────────────────────────────────────────────────────────────────────
data "aws_availability_zones" "available" {
  state = "available"

  # Exclude us-east-1e (t3.micro not available there)
  filter {
    name   = "zone-name"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 4. Latest Ubuntu 22.04 AMI — filter by name, owner, virtualization type
# ──────────────────────────────────────────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 5. Default VPC — same pattern as Chapter 2
# ──────────────────────────────────────────────────────────────────────────────
data "aws_vpc" "default" {
  default = true
}

# ──────────────────────────────────────────────────────────────────────────────
# 6. Default Subnets — filtered by VPC (excluding us-east-1e)
# ──────────────────────────────────────────────────────────────────────────────
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = data.aws_availability_zones.available.zone_ids
  }
}

# Fetch detailed info for each subnet
data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# ──────────────────────────────────────────────────────────────────────────────
# 7. AWS Partition — useful for ARN construction (e.g., aws, aws-cn, aws-us-gov)
# ──────────────────────────────────────────────────────────────────────────────
data "aws_partition" "current" {}

# ──────────────────────────────────────────────────────────────────────────────
# RESOURCES — use discovered data to create infrastructure
# ──────────────────────────────────────────────────────────────────────────────

# Security group using discovered VPC
resource "aws_security_group" "web" {
  name        = "chapter3-data-sources-sg"
  description = "Security group for data sources demo"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "chapter3-data-sources-sg"
    Environment = var.environment
    Chapter     = "03-data-sources"
  }
}

# EC2 instance using dynamically discovered AMI
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "Hello from data-sources demo (AMI: ${data.aws_ami.ubuntu.id})" > /var/www/html/index.html
  EOF

  tags = {
    Name                 = "chapter3-data-sources"
    Environment          = var.environment
    "Discovered:Account" = data.aws_caller_identity.current.account_id
    "Discovered:Region"  = data.aws_region.current.name
  }
}
