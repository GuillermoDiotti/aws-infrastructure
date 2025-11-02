/*resource "aws_amplify_app" "react_app" {
  name                 = var.app_name
  repository           = var.github_repository
  platform             = "WEB"
  access_token         = var.github_token
  iam_service_role_arn = aws_iam_role.amplify_role.arn

  build_spec = file("${path.module}/amplify.yml")

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

# ============================================
# WEBHOOK PARA BUILDS AUTOMÁTICOS
# ============================================

resource "aws_amplify_webhook" "main" {
  app_id      = aws_amplify_app.react_app.id
  branch_name = aws_amplify_branch.main.branch_name
  description = "Webhook para builds automáticos en ${var.branch_name}"
}*/