output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_endpoint" {
  description = "API Gateway invoke URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "articles_resource_id" {
  description = "Resource ID for /articles"
  value       = aws_api_gateway_resource.articles.id
}

output "article_id_resource_id" {
  description = "Resource ID for /articles/{id}"
  value       = aws_api_gateway_resource.article_id.id
}