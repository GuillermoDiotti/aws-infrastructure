# ============================================
# SECRETS MANAGER - Bedrock Configuration
# ============================================

resource "aws_secretsmanager_secret" "bedrock_config" {
  name        = "${var.project_name}/bedrock/config"
  description = "Bedrock model configuration for AI article generation"

  tags = {
    Name = "${var.project_name}-bedrock-config"
  }
}

resource "aws_secretsmanager_secret_version" "bedrock_config" {
  secret_id = aws_secretsmanager_secret.bedrock_config.id

  secret_string = jsonencode({
    model_id              = var.bedrock_model_id
    temperature           = var.bedrock_temperature
    max_tokens            = var.bedrock_max_tokens
    anthropic_version     = "bedrock-2023-05-31"
    default_topic         = "technology"
    default_style         = "informative"
    default_length        = "medium"
  })
}

# ============================================
# IAM POLICY - Permitir que Lambdas lean el secret
# ============================================



resource "aws_secretsmanager_secret_policy" "bedrock_config" {
  secret_arn = aws_secretsmanager_secret.bedrock_config.arn
  policy     = data.aws_iam_policy_document.secret_access.json
}