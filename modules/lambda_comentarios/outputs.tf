output "create_comentario_function_name" {
  description = "Create Comentario Lambda function name"
  value       = aws_lambda_function.create_comentario.function_name
}

output "create_comentario_function_arn" {
  description = "Create Comentario Lambda function ARN"
  value       = aws_lambda_function.create_comentario.arn
}

output "create_comentario_invoke_arn" {
  description = "Create Comentario Lambda invoke ARN (for API Gateway)"
  value       = aws_lambda_function.create_comentario.invoke_arn
}

output "get_comentarios_function_name" {
  description = "Get Comentarios Lambda function name"
  value       = aws_lambda_function.get_comentarios.function_name
}

output "get_comentarios_function_arn" {
  description = "Get Comentarios Lambda function ARN"
  value       = aws_lambda_function.get_comentarios.arn
}

output "get_comentarios_invoke_arn" {
  description = "Get Comentarios Lambda invoke ARN (for API Gateway)"
  value       = aws_lambda_function.get_comentarios.invoke_arn
}

# Agregar a modules/lambda_comentarios/outputs.tf:

output "create_comentario_log_group" {
  description = "CloudWatch log group name for create_comentario"
  value       = aws_cloudwatch_log_group.create_comentario.name
}

output "get_comentarios_log_group" {
  description = "CloudWatch log group name for get_comentarios"
  value       = aws_cloudwatch_log_group.get_comentarios.name
}