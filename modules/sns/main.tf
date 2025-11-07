# ============================================
# SNS TOPIC - Article Notifications
# ============================================

resource "aws_sns_topic" "article_notifications" {
  name         = "${var.project_name}-article-notifications"
  display_name = "AI Article Generation Notifications"

  tags = {
    Name = "${var.project_name}-article-notifications"
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

# ============================================
# SNS SUBSCRIPTION - Lambda (Discord)
# ============================================