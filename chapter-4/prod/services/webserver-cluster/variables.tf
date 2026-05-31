variable "cluster_name" {
  description = "Name prefix for the webserver cluster"
  type        = string
  default     = "webserver-prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "server_port" {
  description = "Port the web server listens on"
  type        = number
  default     = 80
}

variable "min_size" {
  description = "Minimum instances in the ASG"
  type        = number
  default     = 5
}

variable "max_size" {
  description = "Maximum instances in the ASG"
  type        = number
  default     = 20
}
