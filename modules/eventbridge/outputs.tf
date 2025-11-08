output "rule_name" {
  description = "EventBridge rule name"
  value       = aws_cloudwatch_event_rule.generate_article_schedule.name
}

output "rule_arn" {
  description = "EventBridge rule ARN"
  value       = aws_cloudwatch_event_rule.generate_article_schedule.arn
}

output "schedule_expression" {
  description = "Schedule expression configured"
  value       = var.schedule_expression
}

# modules/eventbridge/outputs.tf - Agregar:

output "eventbridge_log_group" {
  description = "CloudWatch log group name for EventBridge"
  value       = aws_cloudwatch_log_group.eventbridge.name
}