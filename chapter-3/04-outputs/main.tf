# ------------------------------------------------------------------------------
# 04-outputs — main.tf
# Creates minimal resources so we can demonstrate advanced output patterns.
# The outputs.tf file is the star of this project.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# DATA SOURCES — for output enrichment
# ──────────────────────────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ──────────────────────────────────────────────────────────────────────────────
# SECURITY GROUP
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "chapter3-advanced-outputs-sg"
  description = "Security group for advanced outputs demo"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "chapter3-advanced-outputs"
    Environment = var.environment
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# EC2 INSTANCE
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = "ami-02fd066b86800f60c"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "Hello from advanced-outputs demo" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "chapter3-advanced-outputs"
    Environment = var.environment
  }
}
