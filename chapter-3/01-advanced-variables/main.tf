# ------------------------------------------------------------------------------
# 01-advanced-variables — main.tf
# Demonstrates advanced variable usage: type constraints, validation, sensitive,
# nullable, objects, tuples, sets, and maps of objects.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# LOCALS
# ──────────────────────────────────────────────────────────────────────────────
locals {
  # Generate user_data script — use custom if provided, else default
  user_data = var.custom_user_data_script != null ? file(var.custom_user_data_script) : templatefile("${path.module}/user_data.tftpl", {
    server_port   = var.web_server_config.server_port
    enable_apache = var.web_server_config.enable_apache
    extra_pkgs    = var.web_server_config.extra_packages
  })

  # Create a security group description from the rules map
  sg_description = "Security group for ${var.tags["Environment"]} environment"
}

# ──────────────────────────────────────────────────────────────────────────────
# SECURITY GROUP with dynamic ingress from a map(object) variable
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "chapter3-advanced-vars-sg"
  description = local.sg_description

  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ──────────────────────────────────────────────────────────────────────────────
# EC2 INSTANCE — uses object variable for config
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.web_server_config.ami_id
  instance_type          = var.web_server_config.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = local.user_data
  monitoring             = var.enable_detailed_monitoring

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "advanced-variables-demo"
  })
}

# Create a null resource with a provisioner to demonstrate sensitive variable
# (Sensitive values are hidden in logs but still usable internally)
resource "null_resource" "sensitive_demo" {
  triggers = {
    # Using a sha256 hash of the password to avoid exposing even the trigger value
    password_hash = sha256(var.db_password)
  }

  provisioner "local-exec" {
    command = "echo 'Password hash (not actual password) stored in state: ${sha256(var.db_password)}'"
  }

  depends_on = [aws_instance.web]
}
