# ------------------------------------------------------------------------------
# MODULE: webserver-cluster — Input Variables
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name prefix for all resources in the cluster"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "server_port" {
  description = "Port the web server listens on"
  type        = number
  default     = 80
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 10
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster into"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy instances into"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
