# ------------------------------------------------------------------------------
# MODULE: data-stores/mysql — Input Variables
# ------------------------------------------------------------------------------

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_user" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "The RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "The MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy (learning only — set to false in production)"
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group to use"
  type        = string
}

variable "webserver_sg_ids" {
  description = "List of security group IDs allowed to connect to MySQL"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
