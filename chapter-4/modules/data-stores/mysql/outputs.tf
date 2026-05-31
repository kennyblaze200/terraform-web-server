# ------------------------------------------------------------------------------
# MODULE: data-stores/mysql — Outputs
# ------------------------------------------------------------------------------

output "db_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.mysql.address
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.mysql.port
}

output "db_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = "${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}"
}

output "db_sg_id" {
  description = "The ID of the MySQL security group"
  value       = aws_security_group.mysql.id
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}
