# modules/centralized_logging/main.tf
resource "aws_cloudwatch_log_group" "central" {
  name              = "/aws/${var.project_name}/central-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-central-logs"
    Environment = "production"
    Purpose     = "centralized-logging"
  }
}
