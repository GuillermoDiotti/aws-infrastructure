# modules/centralized_logging/outputs.tf
output "central_log_group_name" {
  value = aws_cloudwatch_log_group.central.name
}