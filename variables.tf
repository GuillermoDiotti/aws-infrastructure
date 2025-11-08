variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "github_token" {
  description = "Personal Access Token de GitHub"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "URL del repositorio de GitHub"
  type        = string
}

variable "app_name" {
  description = "Nombre de la aplicación en Amplify"
  type        = string
}

variable "branch_name" {
  description = "Nombre de la rama principal"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for second private subnet"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock model ID for AI generation"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "article_generation_schedule" {
  description = "Schedule expression for automatic article generation"
  type        = string
}

variable "static_site_cache_ttl" {
  description = "Default TTL for CloudFront cache (seconds)"
  type        = number
}

variable "static_site_cache_max_ttl" {
  description = "Max TTL for CloudFront cache (seconds)"
  type        = number
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
}