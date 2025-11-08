# ============================================
# EVENTBRIDGE RULE - Scheduled Article Generation
# ============================================

resource "aws_cloudwatch_event_rule" "generate_article_schedule" {
  name                = "${var.project_name}-generate-article-schedule"
  description         = "Trigger article generation every 15 minutes"
  schedule_expression = var.schedule_expression

  event_bus_name = "default"

  tags = {
    Name = "${var.project_name}-generate-article-schedule"
  }
}

# ============================================
# EVENT TARGET - Lambda
# ============================================

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.generate_article_schedule.name
  target_id = "GenerateArticleLambda"
  arn       = var.lambda_function_arn

  # Payload que se envía a la Lambda
  input = jsonencode({
    topic  = "technology"
    style  = "informative"
    length = "medium"
    source = "eventbridge"
  })
}

# ============================================
# LAMBDA PERMISSION - Permitir EventBridge invocar Lambda
# ============================================

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.generate_article_schedule.arn
}

# modules/eventbridge/main.tf - Agregar al final:

resource "aws_cloudwatch_log_group" "eventbridge" {
  name              = "/aws/events/${var.project_name}-schedule"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-eventbridge-logs"
  }
}

# Habilitar logging en la regla
