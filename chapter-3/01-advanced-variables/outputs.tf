# ------------------------------------------------------------------------------
# 01-advanced-variables — outputs.tf
# Demonstrates output type constraints and description practices.
# ------------------------------------------------------------------------------

output "instance_id" {
  description = "The ID of the web server EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.web.name
}

# Sensitive output — will not display the actual value
output "db_password_hash" {
  description = "SHA256 hash of the database password (actual password is sensitive)"
  value       = sha256(var.db_password)
  sensitive   = true
}

output "used_variable_types" {
  description = "Summary of the variable types demonstrated in this project"
  value = {
    string       = "instance_type"
    number       = "root_volume_size"
    bool         = "enable_detailed_monitoring"
    "list(string)" = "security_group_cidr_blocks"
    "map(string)"  = "tags"
    object       = "web_server_config"
    tuple        = "network_config"
    "set(string)"  = "availability_zones"
    "map(object)"  = "security_group_rules"
    sensitive    = "db_password"
    nullable     = "custom_user_data_script"
  }
}
