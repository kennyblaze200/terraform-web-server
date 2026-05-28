# ------------------------------------------------------------------------------
# 02-locals — main.tf
# Demonstrates local values: computed naming, merged tags, conditional logic,
# and complex expressions that simplify resource declarations.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# DATA SOURCES — used inside locals for conditional AMI lookup
# ──────────────────────────────────────────────────────────────────────────────
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
# LOCALS — the star of this example
# ──────────────────────────────────────────────────────────────────────────────
locals {
  # Computed name prefix — reduces repetition across multiple resources
  name_prefix = "${var.project_name}-${var.environment}"

  # Conditional AMI selection: custom AMI if provided, otherwise latest Ubuntu
  ami_id = var.custom_ami_id != null ? var.custom_ami_id : data.aws_ami.ubuntu.id

  # Merged tags: base tags take lowest priority, then environment/project tags,
  # then the Name tag (highest priority)
  common_tags = merge(var.base_tags, {
    Name        = "${local.name_prefix}-server"
    Environment = var.environment
    Chapter     = "03-locals"
  })

  # Conditional backup tags — only add backup-related tags if backups enabled
  backup_tags = var.enable_backup ? {
    Backup      = "enabled"
    BackupPlan  = "daily"
    Retention   = "7-days"
  } : {
    Backup = "disabled"
  }

  # Merge everything into a single comprehensive tag map
  all_tags = merge(local.common_tags, local.backup_tags)

  # Security group rules — computed based on environment
  # Learning environments get tighter rules than prod
  ingress_rules = var.environment == "learning" ? {
    http = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ssh = {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Note: in prod, this would be a specific IP
    }
  } : {
    http = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # User data script — generated from template
  user_data = templatefile("${path.module}/user_data.tftpl", {
    env_name      = var.environment
    project       = var.project_name
    feature_flags = var.environment == "learning" ? "debug=true" : "debug=false"
  })
}

# ──────────────────────────────────────────────────────────────────────────────
# RESOURCES — notice how clean they become using locals
# ──────────────────────────────────────────────────────────────────────────────

# Security group — uses locals for name, tags, and rules
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Security group for ${local.name_prefix} web server"

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.all_tags
}

# EC2 instance — uses locals for name, ami, tags
resource "aws_instance" "web" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = local.user_data

  tags = local.all_tags
}

# Demonstrate that locals are reusable across multiple resources
resource "null_resource" "metadata_printer" {
  triggers = {
    name_prefix  = local.name_prefix
    ami_used     = local.ami_id
    environment  = var.environment
    tag_count    = length(local.all_tags)
  }

  provisioner "local-exec" {
    command = "echo 'Locals demo: prefix=${local.name_prefix}, tags=${length(local.all_tags)}, env=${var.environment}'"
  }

  depends_on = [aws_instance.web]
}
