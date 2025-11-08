# modules/centralized_logging/variables.tf
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "log_retention_days" {
  description = "Days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

variable "log_group_names" {
  description = "List of CloudWatch log group names to subscribe"
  type        = list(string)
}