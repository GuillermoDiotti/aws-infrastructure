variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "cache_default_ttl" {
  description = "Default TTL for CloudFront cache in seconds"
  type        = number
  default     = 3600  # 1 hora
}

variable "cache_max_ttl" {
  description = "Maximum TTL for CloudFront cache in seconds"
  type        = number
  default     = 86400  # 24 horas
}

variable "cache_min_ttl" {
  description = "Minimum TTL for CloudFront cache in seconds"
  type        = number
  default     = 0
}

variable "price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"  # Solo NA y Europa (más barato)

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "enable_compression" {
  description = "Enable gzip compression in CloudFront"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "index_document" {
  description = "Index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the website"
  type        = string
  default     = "error.html"
}