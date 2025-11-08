output "generate_article_function_name" {
  description = "Generate Article Lambda function name"
  value       = aws_lambda_function.generate_article.function_name
}

output "generate_article_function_arn" {
  description = "Generate Article Lambda function ARN"
  value       = aws_lambda_function.generate_article.arn
}

output "generate_article_invoke_arn" {
  description = "Generate Article Lambda invoke ARN (for API Gateway)"
  value       = aws_lambda_function.generate_article.invoke_arn
}

output "get_article_function_name" {
  description = "Get Article Lambda function name"
  value       = aws_lambda_function.get_article.function_name
}

output "get_article_function_arn" {
  description = "Get Article Lambda function ARN"
  value       = aws_lambda_function.get_article.arn
}

output "get_article_invoke_arn" {
  description = "Get Article Lambda invoke ARN (for API Gateway)"
  value       = aws_lambda_function.get_article.invoke_arn
}

# Agregar a modules/lambda_articulos/outputs.tf:

output "generate_article_log_group" {
  description = "CloudWatch log group name for generate_article"
  value       = aws_cloudwatch_log_group.generate_article.name
}

output "get_article_log_group" {
  description = "CloudWatch log group name for get_article"
  value       = aws_cloudwatch_log_group.get_article.name
}