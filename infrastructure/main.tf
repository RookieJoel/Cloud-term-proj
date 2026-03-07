#VPC
module "vpc" {
  source = "./modules/vpc"

  cidr_block            = "10.0.0.0/16"
  public_subnet_cidr    = "10.0.1.0/24"
  private_subnet_a_cidr = "10.0.2.0/24"
  private_subnet_b_cidr = "10.0.3.0/24"
  availability_zone_a   = var.availability_zone_a
  availability_zone_b   = var.availability_zone_b
}

#Security
module "security" {
  source = "./modules/security"

  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_id
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
}

#RDS
module "database" {
  source = "./modules/database"

  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
  db_sg_id            = module.security.db_sg_id
  database_name       = var.database_name
  database_user       = var.database_user
  database_pass       = var.database_pass
}

#S3
module "storage" {
  source = "./modules/storage"

  bucket_name = var.bucket_name
}

#EC2
module "compute" {
  source = "./modules/compute"

  ami                       = var.ami
  public_subnet_id          = module.vpc.public_subnet_id
  private_subnet_id         = module.vpc.private_subnet_a_id
  wordpress_sg_id           = module.security.wordpress_sg_id
  iam_instance_profile_name = module.storage.iam_instance_profile_name

  db_endpoint = module.database.rds_endpoint
  db_name     = var.database_name
  db_user     = var.database_user
  db_pass     = var.database_pass

  admin_user = var.admin_user
  admin_pass = var.admin_pass

  bucket_name   = module.storage.bucket_name
  bucket_region = module.storage.bucket_region
}

#out
output "wordpress_public_ip" {
  description = "Elastic IP of the WordPress server: http://<this-ip>/wp-admin"
  value       = module.compute.wordpress_public_ip
}

output "rds_endpoint" {
  description = "RDS MariaDB endpoint"
  value       = module.database.rds_endpoint
}
