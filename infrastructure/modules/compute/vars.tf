variable "ami" {
  description = "Ubuntu 24.04 AMI ID"
  type        = string
}

variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "wordpress_sg_id" { type = string }
variable "iam_instance_profile_name" { type = string }

variable "db_endpoint" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_pass" {
  type      = string
  sensitive = true
}

variable "admin_user" {
  description = "WordPress admin username"
  type        = string
}

variable "admin_pass" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
}

variable "bucket_name" { type = string }
variable "bucket_region" { type = string }
