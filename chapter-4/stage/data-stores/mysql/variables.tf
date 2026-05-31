variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "stagedb"
}

variable "db_user" {
  description = "The username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database (CHANGE BEFORE APPLY)"
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
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = true
}
