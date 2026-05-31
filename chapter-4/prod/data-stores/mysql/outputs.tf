output "db_address" {
  description = "The address of the RDS instance"
  value       = module.mysql.db_address
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = module.mysql.db_port
}

output "db_endpoint" {
  description = "The connection endpoint"
  value       = module.mysql.db_endpoint
}

output "db_sg_id" {
  description = "The ID of the MySQL security group"
  value       = module.mysql.db_sg_id
}
