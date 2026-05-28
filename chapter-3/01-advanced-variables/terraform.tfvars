# ──────────────────────────────────────────────────────────────────────────────
# terraform.tfvars — Override default variable values
# ──────────────────────────────────────────────────────────────────────────────

instance_type         = "t3.micro"
root_volume_size      = 10
enable_detailed_monitoring = false

web_server_config = {
  instance_type  = "t3.micro"
  server_port    = 80
  enable_apache  = true
  extra_packages = ["curl", "htop"]
}

# Replace with a real password for apply (this is a placeholder)
db_password = "ChangeMe12345!"

security_group_rules = {
  http = {
    port        = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }
}
