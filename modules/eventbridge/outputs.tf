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