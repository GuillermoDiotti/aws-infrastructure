variable "project_name" {
  description = "Project name"
  type        = string
}

variable "monthly_budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
}

variable "notification_email" {
  description = "Email for budget notifications"
  type        = string
}