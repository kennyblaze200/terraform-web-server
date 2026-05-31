# ------------------------------------------------------------------------------
# MODULE: data-stores/mysql
# Reusable RDS MySQL module with security group.
# Called from stage/ and prod/ environments with different variables.
#
# IMPORTANT: This module does NOT contain a provider configuration.
# Providers are inherited from the calling root module.
# ------------------------------------------------------------------------------

# Security group allowing MySQL access on port 3306
resource "aws_security_group" "mysql" {
  name_prefix = "${var.db_name}-mysql-sg-"
  description = "Security group for MySQL database ${var.db_name}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.webserver_sg_ids
    cidr_blocks     = length(var.webserver_sg_ids) > 0 ? null : ["0.0.0.0/0"]
    self            = false
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.db_name}-mysql-sg"
  })
}

# RDS MySQL instance
resource "aws_db_instance" "mysql" {
  identifier     = var.db_name
  db_name        = var.db_name
  username       = var.db_user
  password       = var.db_password
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_encrypted     = true
  skip_final_snapshot   = var.skip_final_snapshot
  publicly_accessible   = false

  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = var.db_subnet_group_name

  tags = merge(var.tags, {
    Name = "${var.db_name}-rds"
  })
}
