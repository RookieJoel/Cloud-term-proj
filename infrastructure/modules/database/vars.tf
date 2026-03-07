variable "private_subnet_a_id" { type = string }
variable "private_subnet_b_id" { type = string }
variable "db_sg_id" { type = string }

variable "database_name" {
  description = "WordPress database name"
  type        = string
}

variable "database_user" {
  description = "Database master username"
  type        = string
}

variable "database_pass" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
