# ------------------------------------------------------------------------------
# Chapter 3 — Data Sources Demo
# Minimal variables — most information is discovered via data sources
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the demo server"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "learning"
}
