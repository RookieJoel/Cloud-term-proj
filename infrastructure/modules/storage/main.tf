#s3
resource "aws_s3_bucket" "wordpress_media" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = { Name = "WordPress-Media-Bucket" }
}

resource "aws_s3_bucket_ownership_controls" "wordpress_media" {
  bucket = aws_s3_bucket.wordpress_media.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "wordpress_media" {
  bucket = aws_s3_bucket.wordpress_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "wordpress_media" {
  depends_on = [
    aws_s3_bucket_ownership_controls.wordpress_media,
    aws_s3_bucket_public_access_block.wordpress_media,
  ]

  bucket = aws_s3_bucket.wordpress_media.id
  acl    = "public-read"
}

#IAM role for Ec2 to access s3
#this is basically defines who is gonna access thee s3, in this case its the EC2 instance.
resource "aws_iam_role" "wordpress_s3" {
  name = "wordpress-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = { Name = "WordPress-S3-Role" }
}

#In this policy, I allow the EC2 to perform the following actions on the S3 bucket (guess these should be enough)
resource "aws_iam_role_policy" "wordpress_s3" {
  name = "wordpress-s3-access"
  role = aws_iam_role.wordpress_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.wordpress_media.arn,
          "${aws_s3_bucket.wordpress_media.arn}/*"
        ]
      }
    ]
  })
}

#this perform like a bridge between the IAM role and the EC2 instance since the EC2 can't use an IAM role directly. 
resource "aws_iam_instance_profile" "wordpress" {
  name = "wordpress-instance-profile"
  role = aws_iam_role.wordpress_s3.name
}
