data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "amplify_role" {
  name = "${var.app_name}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "${var.app_name}-amplify-role"
    ManagedBy = "terraform"
    Project   = "cloud-react"
  }
}

# Usar la política administrada recomendada por AWS para Amplify
resource "aws_iam_role_policy_attachment" "amplify_admin" {
  role       = aws_iam_role.amplify_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# Política adicional para logs (por si acaso)
resource "aws_iam_role_policy" "amplify_logs" {
  name = "${var.app_name}-logs-policy"
  role = aws_iam_role.amplify_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/amplify/*"
      }
    ]
  })
}

resource "aws_amplify_app" "react_app" {
  name                 = var.app_name
  repository           = var.github_repository
  platform             = "WEB"
  access_token         = var.github_token
  iam_service_role_arn = aws_iam_role.amplify_role.arn

  build_spec = file("${path.root}/amplify.yml")

  # Variables de entorno
  environment_variables = {
    _LIVE_UPDATES = "[{\"pkg\":\"node\",\"type\":\"nvm\",\"version\":\"20\"}]"
  }

  # Regla SPA - Fundamental para React Router
  # Redirige todas las rutas (excepto archivos estáticos) al index.html
  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = {
    Name        = var.app_name
    ManagedBy   = "terraform"
    Project     = "cloud-react"
    Environment = "production"
  }
}

# ============================================
# AMPLIFY BRANCH
# ============================================

resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.react_app.id
  branch_name       = var.branch_name
  framework         = "React"
  stage             = "PRODUCTION"
  enable_auto_build = true

  environment_variables = {
    VITE_ENV = "production"
  }

  tags = {
    Name        = "${var.app_name}-${var.branch_name}"
    Environment = "production"
  }
}


resource "aws_amplify_webhook" "main" {
  app_id      = aws_amplify_app.react_app.id
  branch_name = aws_amplify_branch.main.branch_name
  description = "Webhook para builds automáticos en ${var.branch_name}"
}

resource "aws_cloudwatch_log_group" "amplify_build" {
  name              = "/aws/amplify/${var.app_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.app_name}-amplify-logs"
  }
}