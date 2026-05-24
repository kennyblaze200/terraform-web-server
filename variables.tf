variable "instance_name" {
  description = "The Name tag for the EC2 instance"
  type        = string
  default     = "terraform-in-depth-lab"
}

variable "instance_type" {
  description = "The EC2 instance type (size)"
  type        = string
  default     = "t3.micro"
}
