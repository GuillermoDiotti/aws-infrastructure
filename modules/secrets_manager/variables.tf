variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock model ID to use"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "bedrock_temperature" {
  description = "Temperature for model generation"
  type        = number
  default     = 0.7
}

variable "bedrock_max_tokens" {
  description = "Maximum tokens to generate"
  type        = number
  default     = 2000
}

variable "lambda_role_arns" {
  description = "List of Lambda role ARNs that need access to secrets"
  type        = list(string)
}