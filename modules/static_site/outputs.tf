output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = aws_s3_bucket.institutional_site.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.institutional_site.arn
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.institutional_site.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.institutional.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.institutional.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution (use this to access the site)"
  value       = aws_cloudfront_distribution.institutional.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of CloudFront (useful for Route53)"
  value       = aws_cloudfront_distribution.institutional.hosted_zone_id
}

output "cloudfront_url" {
  description = "Full HTTPS URL to access the institutional site"
  value       = "https://${aws_cloudfront_distribution.institutional.domain_name}"
}

output "origin_access_identity_arn" {
  description = "ARN of the CloudFront Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.institutional.iam_arn
}

output "cache_configuration" {
  description = "Cache configuration summary"
  value = {
    default_ttl = var.cache_default_ttl
    max_ttl     = var.cache_max_ttl
    min_ttl     = var.cache_min_ttl
    compression = var.enable_compression
  }
}

output "upload_command" {
  description = "Command to upload files to S3"
  value       = "aws s3 sync ./institutional-site/ s3://${aws_s3_bucket.institutional_site.id}/"
}

output "invalidation_command" {
  description = "Command to invalidate CloudFront cache"
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.institutional.id} --paths '/*'"
}