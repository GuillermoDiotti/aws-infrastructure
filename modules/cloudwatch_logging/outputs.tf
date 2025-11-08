# modules/centralized_logging/outputs.tf
output "central_log_group_name" {
  value = aws_cloudwatch_log_group.central.name
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}