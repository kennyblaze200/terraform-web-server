# ------------------------------------------------------------------------------
# 06-remote-state — main.tf
# Demonstrates the terraform_remote_state data source to read outputs
# from another Terraform project's state file.
#
# PREREQUISITE: Before using this, the 05-module-consumer project must be
# applied with a remote S3 backend configured.
#
# This project reads the ALB DNS name from the consumer's state and
# could use it to configure DNS (Route53) or pass to another system.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# TERRAFORM REMOTE STATE — reads outputs from another project's state
# ──────────────────────────────────────────────────────────────────────────────
data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
    region = var.remote_state_region
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# LOCALS — extract values from the remote state outputs
# ──────────────────────────────────────────────────────────────────────────────
locals {
  # Read module outputs from the remote state
  alb_dns_name = try(data.terraform_remote_state.cluster.outputs.alb_dns_name, "NOT FOUND — apply 05-module-consumer first with S3 backend")
  asg_name     = try(data.terraform_remote_state.cluster.outputs.asg_name, "NOT FOUND")
}

# ──────────────────────────────────────────────────────────────────────────────
# RESOURCES — use remote state data to create dependent infrastructure
# ──────────────────────────────────────────────────────────────────────────────

# Example: Create a Route53 DNS record pointing to the ALB
# (Commented out because it requires a real hosted zone)
# resource "aws_route53_record" "app" {
#   zone_id = var.hosted_zone_id
#   name    = "app.example.com"
#   type    = "A"
#   alias {
#     name                   = local.alb_dns_name
#     zone_id                = try(data.terraform_remote_state.cluster.outputs.alb_zone_id, "")
#     evaluate_target_health = true
#   }
# }

# Demo: A null_resource that shows how remote state data can be consumed
resource "null_resource" "remote_state_demo" {
  triggers = {
    alb_dns_name = local.alb_dns_name
    asg_name     = local.asg_name
  }

  provisioner "local-exec" {
    command = "echo 'Remote state: ALB=${local.alb_dns_name}, ASG=${local.asg_name}'"
  }
}
