variable "project_name" {
  description = "Project name"
  type        = string
}

variable "lambda_functions" {
  description = "Map of lambda function names to monitor"
  type        = map(string)
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "duration_threshold_ms" {
  description = "Duration threshold in milliseconds"
  type        = number
  default     = 10000
}