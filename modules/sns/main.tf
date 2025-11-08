# ============================================
# SNS TOPIC - Article Notifications
# ============================================

resource "aws_sns_topic" "article_notifications" {
  name         = "${var.project_name}-article-notifications"
  display_name = "AI Article Generation Notifications"

  http_success_feedback_role_arn    = aws_iam_role.sns_logging.arn
  http_failure_feedback_role_arn    = aws_iam_role.sns_logging.arn
  lambda_success_feedback_role_arn  = aws_iam_role.sns_logging.arn
  lambda_failure_feedback_role_arn  = aws_iam_role.sns_logging.arn

  tags = {
    Name = "${var.project_name}-article-notifications"
  }
}

resource "aws_sns_topic" "comment_notifications" {
  name         = "${var.project_name}-comment-notifications"
  display_name = "Comment Publish Notifications"

  http_success_feedback_role_arn    = aws_iam_role.sns_logging.arn
  http_failure_feedback_role_arn    = aws_iam_role.sns_logging.arn
  lambda_success_feedback_role_arn  = aws_iam_role.sns_logging.arn
  lambda_failure_feedback_role_arn  = aws_iam_role.sns_logging.arn

  tags = {
    Name = "${var.project_name}-comment-notifications"
  }
}


# ============================================
# SNS SUBSCRIPTION - Email
# ============================================

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.article_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email

  # Nota: Requiere confirmación manual del usuario vía email
}

resource "aws_sns_topic_subscription" "email2" {
  topic_arn = aws_sns_topic.comment_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email

  # Nota: Requiere confirmación manual del usuario vía email
}

resource "aws_iam_role" "sns_logging" {
  name = "${var.project_name}-sns-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sns_logging" {
  role = aws_iam_role.sns_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_cloudwatch_log_group" "sns" {
  name              = "/aws/sns/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-sns-logs"
  }
}