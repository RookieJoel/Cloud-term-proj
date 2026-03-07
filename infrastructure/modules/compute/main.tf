#ENI for WP
resource "aws_network_interface" "wp_public_eni" {
  subnet_id       = var.public_subnet_id
  security_groups = [var.wordpress_sg_id]

  tags = { Name = "WordPress-Public-ENI" }
}

resource "aws_network_interface" "wp_private_eni" {
  subnet_id       = var.private_subnet_id
  security_groups = [var.wordpress_sg_id]

  tags = { Name = "WordPress-Private-ENI" }
}

#EC2 - WP
resource "aws_instance" "wordpress" {
  ami                  = var.ami
  instance_type        = "t2.micro"
  iam_instance_profile = var.iam_instance_profile_name

  network_interface {
    network_interface_id = aws_network_interface.wp_public_eni.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.wp_private_eni.id
    device_index         = 1
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_host       = var.db_endpoint
    db_name       = var.db_name
    db_user       = var.db_user
    db_pass       = var.db_pass
    admin_user    = var.admin_user
    admin_pass    = var.admin_pass
    bucket_name   = var.bucket_name
    bucket_region = var.bucket_region
    eip           = aws_eip.wordpress.public_ip
  }))

  tags = { Name = "WordPress-Server" }

  depends_on = [aws_eip.wordpress]
}

#EIP
resource "aws_eip" "wordpress" {
  domain = "vpc"
  tags   = { Name = "WordPress-EIP" }
}

resource "aws_eip_association" "wordpress" {
  allocation_id        = aws_eip.wordpress.id
  network_interface_id = aws_network_interface.wp_public_eni.id
}
