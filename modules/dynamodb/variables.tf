variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB (tiene costo adicional)"
  type        = bool
  default     = false
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams for change data capture"
  type        = bool
  default     = false
}