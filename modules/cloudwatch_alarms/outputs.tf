output "error_alarm_arns" {
  description = "ARNs of error alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_errors : k => v.arn }
}

output "throttle_alarm_arns" {
  description = "ARNs of throttle alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_throttles : k => v.arn }
}

output "duration_alarm_arns" {
  description = "ARNs of duration alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_duration : k => v.arn }
}