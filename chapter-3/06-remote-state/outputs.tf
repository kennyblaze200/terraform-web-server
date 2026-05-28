# ------------------------------------------------------------------------------
# 06-remote-state — outputs.tf
# Demonstrates reading and exposing outputs from remote state
# ------------------------------------------------------------------------------

output "remote_alb_dns_name" {
  description = "ALB DNS name read from the remote state of 05-module-consumer"
  value       = local.alb_dns_name
}

output "remote_asg_name" {
  description = "ASG name read from the remote state of 05-module-consumer"
  value       = local.asg_name
}

output "remote_state_config" {
  description = "Configuration used to access the remote state"
  value = {
    backend = "s3"
    bucket  = var.remote_state_bucket
    key     = var.remote_state_key
    region  = var.remote_state_region
  }
}

output "remote_state_demo_summary" {
  description = "Summary of remote state concepts demonstrated"
  value = {
    data_source            = "terraform_remote_state"
    backend                = "s3"
    consuming              = "module.webserver_cluster.outputs from 05-module-consumer"
    use_case               = "Cross-project state sharing (e.g., DNS registration)"
    prerequisite           = "05-module-consumer must have S3 backend configured and applied"
  }
}
