output "bedrock_config_secret_arn" {
  description = "ARN of the Bedrock configuration secret"
  value       = aws_secretsmanager_secret.bedrock_config.arn
}

output "bedrock_config_secret_name" {
  description = "Name of the Bedrock configuration secret"
  value       = aws_secretsmanager_secret.bedrock_config.name
}

output "bedrock_model_id" {
  description = "Bedrock model ID configured"
  value       = var.bedrock_model_id
}