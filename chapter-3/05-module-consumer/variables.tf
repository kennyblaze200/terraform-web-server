# ------------------------------------------------------------------------------
# 05-module-consumer — Variables
# These are passed into the webserver-cluster module
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name prefix for the webserver cluster"
  type        = string
  default     = "terraform-module-demo"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum instances in the ASG"
  type        = number
  default     = 5
}

variable "server_port" {
  description = "Port the web server listens on"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "learning"
}
