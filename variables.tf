variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "obligatorio-2"
}


variable "github_token" {
  description = "Personal Access Token de GitHub"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "URL del repositorio de GitHub"
  type        = string
  default     = "https://github.com/GuillermoDiotti/my-cloud-react-page"
}

variable "app_name" {
  description = "Nombre de la aplicación en Amplify"
  type        = string
  default     = "my-cloud-react-app"
}

variable "branch_name" {
  description = "Nombre de la rama principal"
  type        = string
  default     = "main"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "bedrock_model_id" {
  description = "Bedrock model ID for AI generation"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "article_generation_schedule" {
  description = "Schedule expression for automatic article generation"
  type        = string
  default     = "rate(15 minutes)"
}

variable "static_site_cache_ttl" {
  description = "Default TTL for CloudFront cache (seconds)"
  type        = number
  default     = 3600  # 1 hora
}


variable "static_site_cache_max_ttl" {
  description = "Max TTL for CloudFront cache (seconds)"
  type        = number
  default     = 86400  # 24 horas
}
