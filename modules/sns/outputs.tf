output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.article_notifications.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.article_notifications.name
}

output "comment_topic_arn" {
  description = "ARN of the SNS topic for comments"
  value       = aws_sns_topic.comment_notifications.arn
}

output "comment_topic_name" {
  description = "Name of the SNS topic for comments"
  value       = aws_sns_topic.comment_notifications.name
}

# modules/sns/outputs.tf - Agregar: