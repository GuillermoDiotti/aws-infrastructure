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
variable "get_comentarios_lambda_function_name" {
  description = "Name of the get_comentarios Lambda function"
  type        = string
}

variable "get_comentarios_lambda_invoke_arn" {
  description = "Invoke ARN of the get_comentarios Lambda function"
  type        = string
}

variable "create_comentario_lambda_function_name" {
  description = "Name of the create_comentario Lambda function"
  type        = string
}

variable "create_comentario_lambda_invoke_arn" {
  description = "Invoke ARN of the create_comentario Lambda function"
  type        = string
}