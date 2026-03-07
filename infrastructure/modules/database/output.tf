output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wordpress_db.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.wordpress_db.port
}
