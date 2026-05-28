# ------------------------------------------------------------------------------
# 02-locals — outputs.tf
# Shows the computed local values so you can inspect them
# ------------------------------------------------------------------------------

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "name_prefix" {
  description = "Computed name prefix from locals"
  value       = local.name_prefix
}

output "ami_id_used" {
  description = "AMI ID selected (custom or auto-discovered)"
  value       = local.ami_id
}

output "common_tags" {
  description = "Merged common tags applied to resources"
  value       = local.common_tags
}

output "all_tags" {
  description = "All tags including conditional backup tags"
  value       = local.all_tags
}

output "ingress_rules_used" {
  description = "Ingress rules computed based on environment"
  value       = local.ingress_rules
}

output "locals_summary" {
  description = "Summary of all local values demonstrated"
  value = {
    computed_naming       = "name_prefix: ${local.name_prefix}"
    conditional_logic     = "ami selection via var.custom_ami_id (ternary)"
    tag_merging           = "merge() with base + env + conditional tags"
    environment_aware     = "ingress rules differ by environment"
    template_rendering    = "user_data.tftpl with local values"
  }
}
