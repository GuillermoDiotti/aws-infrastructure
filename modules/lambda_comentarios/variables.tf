variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of IAM role for Lambda"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for Lambda functions"
  type        = string
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for notifications"
  type        = string
}