# WordPress on AWS — Terraform Infrastructure

A fully automated WordPress deployment on AWS using Terraform (OpenTofu), featuring an EC2 instance, RDS MariaDB database, and S3 media storage.

## Architecture

<img width="1382" height="1260" alt="image" src="https://github.com/user-attachments/assets/f65c0cd3-809e-4d59-8083-ded801514c27" />


## AWS Resources

| Resource | Details |
|----------|---------|
| **VPC** | `10.0.0.0/16` with DNS support enabled |
| **Subnets** | 1 public + 2 private (across 2 AZs) |
| **EC2** | `t2.micro`, Ubuntu 24.04 LTS, Apache + PHP 8.3 |
| **RDS** | MariaDB 11.8.5, `db.t3.micro`, private-only |
| **S3** | Public-read bucket for WordPress media (via WP Offload Media plugin) |
| **Security** | NACLs + Security Groups (WordPress SG, DB SG) |
| **IAM** | EC2 instance profile with scoped S3 access |
| **Elastic IP** | Static public IP for the WordPress instance |

## Terraform Modules

```
infrastructure/
├── main.tf              # Root module — wires all modules together
├── vars.tf              # Input variable declarations
├── terraform.tfvars     # Non-sensitive variable values
├── private.tfvars       # Sensitive values (passwords) — NOT committed
├── provider.tf          # AWS provider configuration
└── modules/
    ├── vpc/             # VPC, subnets, IGW, route tables
    ├── security/        # NACLs, security groups
    ├── database/        # RDS MariaDB instance + subnet group
    ├── storage/         # S3 bucket, IAM role & instance profile
    └── compute/         # EC2 instance, ENIs, EIP, userdata script
```

## Prerequisites

- [OpenTofu](https://opentofu.org/) or [Terraform](https://www.terraform.io/) installed
- AWS CLI configured with a named profile
- An AWS account with permissions to create VPC, EC2, RDS, S3, and IAM resources

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/Cloud-term-proj.git
cd Cloud-term-proj/infrastructure
```

### 2. Create your `private.tfvars`

This file holds sensitive credentials and is **git-ignored**. Create it manually:

```hcl
database_pass = "your-secure-db-password"
admin_pass    = "your-secure-wp-admin-password"
```

### 3. Review and edit `terraform.tfvars`

Adjust region, AMI, bucket name, and other non-sensitive values as needed:

```hcl
region              = "ap-southeast-1"
availability_zone_a = "ap-southeast-1a"
availability_zone_b = "ap-southeast-1b"
ami                 = "ami-0ed0867532b47cc2c"   # Ubuntu 24.04 in ap-southeast-1
bucket_name         = "your-unique-bucket-name"
database_name       = "wordpress"
database_user       = "admin"
admin_user          = "admin"
aws_profile         = "your-aws-profile"
```

### 4. Initialize and apply

```bash
tofu init
tofu plan -var-file="private.tfvars"
tofu apply -var-file="private.tfvars"
```

### 5. Access WordPress

After `apply` completes, the output will display:

- **`wordpress_public_ip`** — visit `http://<ip>/wp-admin` to log in
- **`rds_endpoint`** — the internal RDS endpoint (for reference)

## Cleanup

```bash
tofu destroy -var-file="private.tfvars"
```

## Security Notes

- **`private.tfvars`** contains database and admin passwords — never commit this file.
- **`terraform.tfstate`** contains the full resource state including secrets — also git-ignored.
- SSH access (port 22) is open to `0.0.0.0/0` in the security group. For production, restrict this to your IP.
- The RDS instance is only accessible from within the VPC via the WordPress security group.

## License

This project was created for the Cloud Computing course (2110524).
