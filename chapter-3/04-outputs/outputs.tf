# ------------------------------------------------------------------------------
# 04-outputs — outputs.tf
# Demonstrates advanced output patterns:
#   1. Basic outputs (with description)
#   2. Sensitive outputs
#   3. Structured outputs (object, map)
#   4. Outputs with for expressions
#   5. Outputs with conditionals
#   6. Preconditions on outputs
#   7. Non-sensitive wrapper for sensitive values
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# 1. BASIC OUTPUT — always include description
# ──────────────────────────────────────────────────────────────────────────────
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

# ──────────────────────────────────────────────────────────────────────────────
# 2. SENSITIVE OUTPUT — value hidden from CLI, but usable in automation
# ──────────────────────────────────────────────────────────────────────────────
output "api_key_preview" {
  description = "A preview of the API key (first 8 chars only)"
  value       = "${substr(var.api_key, 0, 8)}..."
  sensitive   = true
}

output "api_key_sha256" {
  description = "SHA256 hash of the API key (safe for logging/comparison)"
  value       = sha256(var.api_key)
  # NOTE: Not marked sensitive — hashes can safely be exposed
}

# ──────────────────────────────────────────────────────────────────────────────
# 3. STRUCTURED OUTPUT — object
# ──────────────────────────────────────────────────────────────────────────────
output "instance_details" {
  description = "Structured summary of the EC2 instance"
  value = {
    id              = aws_instance.web.id
    ami             = aws_instance.web.ami
    instance_type   = aws_instance.web.instance_type
    public_ip       = aws_instance.web.public_ip
    private_ip      = aws_instance.web.private_ip
    availability_zone = aws_instance.web.availability_zone
    subnet_id       = aws_instance.web.subnet_id
    vpc_security_group_ids = aws_instance.web.vpc_security_group_ids
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 4. OUTPUT WITH FOR EXPRESSION — transform a list
# ──────────────────────────────────────────────────────────────────────────────
output "security_group_ingress_summary" {
  description = "Summary of all ingress rules on the security group"
  value = [
    for rule in aws_security_group.web.ingress :
    {
      port     = rule.from_port
      protocol = rule.protocol
      cidrs    = rule.cidr_blocks
      description = try(rule.description, "N/A")
    }
  ]
}

# ──────────────────────────────────────────────────────────────────────────────
# 5. CONDITIONAL OUTPUT — different values based on environment
# ──────────────────────────────────────────────────────────────────────────────
output "environment_info" {
  description = "Environment-specific information"
  value = {
    name           = var.environment
    is_production  = var.environment == "prod"
    is_learning    = var.environment == "learning"
    instance_count = var.environment == "prod" ? "scale-to-10" : "single-instance"
    backup_policy  = var.environment == "prod" ? "daily-backups-enabled" : "no-backups"
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 6. OUTPUT WITH PRECONDITION — validate the output value
# ──────────────────────────────────────────────────────────────────────────────
output "validated_instance_id" {
  description = "The instance ID, validated to be non-empty"
  value       = aws_instance.web.id

  precondition {
    condition     = aws_instance.web.id != ""
    error_message = "Instance ID must not be empty after creation."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 7. MAP OUTPUT — using merge and for expressions
# ──────────────────────────────────────────────────────────────────────────────
output "resource_tags_map" {
  description = "All tags from all resources, organized by resource type"
  value = merge(
    { for k, v in aws_security_group.web.tags : "sg:${k}" => v },
    { for k, v in aws_instance.web.tags : "instance:${k}" => v },
  )
}

# ──────────────────────────────────────────────────────────────────────────────
# 8. SUMMARY OUTPUT — what was demonstrated
# ──────────────────────────────────────────────────────────────────────────────
output "output_patterns_demonstrated" {
  description = "Summary of all output patterns shown in this project"
  value = {
    "basic_output"          = "instance_id, instance_public_ip (simple values)"
    "sensitive_output"      = "api_key_preview (hidden from CLI)"
    "structured_object"     = "instance_details (nested object)"
    "for_expression"        = "security_group_ingress_summary (list transformation)"
    "conditional"           = "environment_info (varies by env)"
    "precondition"          = "validated_instance_id (post-condition check)"
    "map_transformation"    = "resource_tags_map (merged from multiple resources)"
    "non_sensitive_hash"    = "api_key_sha256 (safe hash exposure)"
  }
}
