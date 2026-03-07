output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_app.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_app_db_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_app_db_b.id
}
