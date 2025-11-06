variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock model ID to use"
  type        = string
  default     = "us.meta.llama3-1-8b-instruct-v1:0"
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