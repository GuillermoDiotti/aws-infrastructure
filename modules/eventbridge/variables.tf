variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule expression for EventBridge (e.g., rate(15 minutes), cron(0 12 * * ? *))"
  type        = string
  default     = "rate(15 minutes)"
}

variable "lambda_function_name" {
  description = "Lambda function name to trigger"
  type        = string
}

variable "lambda_function_arn" {
  description = "Lambda function ARN to trigger"
  type        = string
}