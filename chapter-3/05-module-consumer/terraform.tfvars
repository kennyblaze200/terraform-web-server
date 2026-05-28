# ──────────────────────────────────────────────────────────────────────────────
# terraform.tfvars — Override default variable values for the module consumer
# ──────────────────────────────────────────────────────────────────────────────

cluster_name  = "terraform-module-demo"
instance_type = "t3.micro"
min_size      = 2
max_size      = 5
server_port   = 80
environment   = "learning"
