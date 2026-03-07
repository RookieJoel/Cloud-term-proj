output "bucket_name" {
  value = aws_s3_bucket.wordpress_media.id
}

output "bucket_region" {
  value = aws_s3_bucket.wordpress_media.region
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.wordpress.name
}
