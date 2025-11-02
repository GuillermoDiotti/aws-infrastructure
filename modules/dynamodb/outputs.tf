output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.ai_articulos.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.ai_articulos.arn
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.ai_articulos.id
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN (if enabled)"
  value       = aws_dynamodb_table.ai_articulos.stream_arn
}

output "gsi_created_at_name" {
  description = "Name of the CreatedAt GSI"
  value       = "CreatedAtIndex"
}

output "gsi_topic_name" {
  description = "Name of the Topic GSI"
  value       = "TopicIndex"
}