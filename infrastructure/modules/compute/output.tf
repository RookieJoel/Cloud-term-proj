output "wordpress_public_ip" {
  description = "Elastic IP of the WordPress instance"
  value       = aws_eip.wordpress.public_ip
}
