# ------------------------------------------------------------------------------
# Chapter 3 — Advanced Variable Features
# Demonstrates: type constraints, validation, sensitive, nullable, defaults
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# 1. Simple type with validation
# ──────────────────────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type — must be free-tier eligible"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t2.nano", "t3.micro", "t3.nano", "t4g.micro", "t4g.nano"], var.instance_type)
    error_message = "Instance type must be a free-tier eligible type (t2.micro, t3.micro, etc.)."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 2. Number with validation
# ──────────────────────────────────────────────────────────────────────────────
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 8 GB and 100 GB."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 3. Boolean
# ──────────────────────────────────────────────────────────────────────────────
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on the EC2 instance"
  type        = bool
  default     = false
}

# ──────────────────────────────────────────────────────────────────────────────
# 4. List of strings
# ──────────────────────────────────────────────────────────────────────────────
variable "security_group_cidr_blocks" {
  description = "CIDR blocks allowed to access the web server"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.security_group_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each value must be a valid CIDR block."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 5. Map of strings (tags)
# ──────────────────────────────────────────────────────────────────────────────
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "learning"
    Chapter     = "03-advanced-variables"
    ManagedBy   = "Terraform"
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 6. Object type — complex nested structure
# ──────────────────────────────────────────────────────────────────────────────
variable "web_server_config" {
  description = "Web server configuration object"
  type = object({
    ami_id         = optional(string, "ami-02fd066b86800f60c") # Ubuntu 22.04 LTS
    instance_type  = string
    server_port    = number
    enable_apache  = bool
    extra_packages = list(string)
  })

  default = {
    instance_type  = "t3.micro"
    server_port    = 80
    enable_apache  = true
    extra_packages = []
  }

  validation {
    condition     = var.web_server_config.server_port >= 80 && var.web_server_config.server_port <= 65535
    error_message = "server_port must be between 80 and 65535."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# 7. Tuple type — fixed positions with different types
# ──────────────────────────────────────────────────────────────────────────────
variable "network_config" {
  description = "Network configuration tuple: [vpc_cidr, subnet_cidrs, enable_dns_support]"
  type = tuple([
    string,        # vpc_cidr
    list(string),  # subnet_cidrs
    bool           # enable_dns_support
  ])
  default = ["10.0.0.0/16", ["10.0.1.0/24", "10.0.2.0/24"], true]
}

# ──────────────────────────────────────────────────────────────────────────────
# 8. Sensitive variable — value hidden in CLI output and logs
# ──────────────────────────────────────────────────────────────────────────────
variable "db_password" {
  description = "Database password — marked as sensitive to prevent exposure"
  type        = string
  sensitive   = true
}

# ──────────────────────────────────────────────────────────────────────────────
# 9. Nullable variable — allows explicit null to use a fallback
# ──────────────────────────────────────────────────────────────────────────────
variable "custom_user_data_script" {
  description = "Custom user_data script path. Set to null to use the default bootstrap script."
  type        = string
  default     = null
  nullable    = true
}

# ──────────────────────────────────────────────────────────────────────────────
# 10. Set of strings — unordered, unique values
# ──────────────────────────────────────────────────────────────────────────────
variable "availability_zones" {
  description = "Set of AZs to deploy into (unordered, duplicates removed)"
  type        = set(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# ──────────────────────────────────────────────────────────────────────────────
# 11. Map of objects — advanced real-world pattern
# ──────────────────────────────────────────────────────────────────────────────
variable "security_group_rules" {
  description = "Map of security group ingress rules"
  type = map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default = {
    http = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
    }
    https = {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from anywhere"
    }
  }
}
