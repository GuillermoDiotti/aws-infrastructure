variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

/*variable "lambda_role_arns" {
  description = "List of Lambda role ARNs that need access to secrets"
  type        = list(string)
}*/