#DB subnet group
resource "aws_db_subnet_group" "wordpress_db" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  tags = { Name = "WordPress-DB-Subnet-Group" }
}

#RDS
resource "aws_db_instance" "wordpress_db" {
  identifier     = "wordpress-mariadb"
  engine         = "mariadb"
  engine_version = "11.8.5"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.database_name
  username = var.database_user
  password = var.database_pass

  db_subnet_group_name   = aws_db_subnet_group.wordpress_db.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = { Name = "WordPress-MariaDB" }
}
