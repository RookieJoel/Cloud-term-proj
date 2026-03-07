variable "region" {
  description = "AWS region to deploy in"
  type        = string
}

variable "availability_zone_a" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_b" {
  description = "Second availability zone"
  type        = string
}

variable "ami" {
  description = "Ubuntu 24.04 LTS AMI ID"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for WordPress media"
  type        = string
}

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

variable "admin_user" {
  description = "WordPress admin username"
  type        = string
}

variable "admin_pass" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}