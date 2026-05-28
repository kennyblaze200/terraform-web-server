# ------------------------------------------------------------------------------
# 03-data-sources — outputs.tf
# Exposes all discovered data source values for inspection
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# Account Information
# ──────────────────────────────────────────────────────────────────────────────
output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the IAM user/role making the API calls"
  value       = data.aws_caller_identity.current.arn
}

output "caller_user_id" {
  description = "Unique ID of the IAM user/role"
  value       = data.aws_caller_identity.current.user_id
}

# ──────────────────────────────────────────────────────────────────────────────
# Region Information
# ──────────────────────────────────────────────────────────────────────────────
output "region_name" {
  description = "Current AWS region name"
  value       = data.aws_region.current.name
}

output "region_description" {
  description = "Current AWS region description"
  value       = data.aws_region.current.description
}

# ──────────────────────────────────────────────────────────────────────────────
# Availability Zones
# ──────────────────────────────────────────────────────────────────────────────
output "availability_zone_names" {
  description = "List of available AZ names in the current region"
  value       = data.aws_availability_zones.available.names
}

output "availability_zone_ids" {
  description = "List of available AZ IDs in the current region"
  value       = data.aws_availability_zones.available.zone_ids
}

# ──────────────────────────────────────────────────────────────────────────────
# AMI Information
# ──────────────────────────────────────────────────────────────────────────────
output "ami_id" {
  description = "ID of the discovered Ubuntu 22.04 AMI"
  value       = data.aws_ami.ubuntu.id
}

output "ami_name" {
  description = "Name of the discovered Ubuntu 22.04 AMI"
  value       = data.aws_ami.ubuntu.name
}

output "ami_creation_date" {
  description = "Creation date of the discovered AMI"
  value       = data.aws_ami.ubuntu.creation_date
}

# ──────────────────────────────────────────────────────────────────────────────
# VPC and Subnet Information
# ──────────────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "vpc_cidr" {
  description = "CIDR block of the default VPC"
  value       = data.aws_vpc.default.cidr_block
}

output "subnet_ids" {
  description = "IDs of all default subnets (excluding us-east-1e)"
  value       = data.aws_subnets.default.ids
}

# Detailed subnet info using for expression
output "subnet_details" {
  description = "Detailed information about each default subnet"
  value = {
    for id, subnet in data.aws_subnet.default :
    id => {
      az          = subnet.availability_zone
      cidr        = subnet.cidr_block
      ipv6_cidr   = subnet.ipv6_cidr_block
      map_public  = subnet.map_public_ip_on_launch
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Partition Information
# ──────────────────────────────────────────────────────────────────────────────
output "aws_partition" {
  description = "AWS partition (e.g., aws, aws-cn, aws-us-gov)"
  value       = data.aws_partition.current.partition
}

# ──────────────────────────────────────────────────────────────────────────────
# Summary output
# ──────────────────────────────────────────────────────────────────────────────
output "data_sources_summary" {
  description = "Summary of all data sources demonstrated"
  value = {
    "aws_caller_identity"  = "Account ID, ARN, User ID"
    "aws_region"           = "Region name and description"
    "aws_availability_zones" = "Available AZ names and IDs"
    "aws_ami"              = "Latest Ubuntu 22.04 AMI"
    "aws_vpc"              = "Default VPC ID and CIDR"
    "aws_subnets"          = "Default subnet IDs"
    "aws_subnet"           = "Per-subnet details (for_each)"
    "aws_partition"        = "AWS partition type"
  }
}
