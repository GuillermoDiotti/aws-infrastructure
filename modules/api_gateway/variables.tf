variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "get_article_lambda_function_name" {
  description = "Name of the get_article Lambda function"
  type        = string
}

variable "get_article_lambda_invoke_arn" {
  description = "Invoke ARN of the get_article Lambda function"
  type        = string
}

variable "generate_article_lambda_function_name" {
  description = "Name of the generate_article Lambda function"
  type        = string
}

variable "generate_article_lambda_invoke_arn" {
  description = "Invoke ARN of the generate_article Lambda function"
  type        = string
}