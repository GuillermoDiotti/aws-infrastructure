terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================
# IAM ROLE PARA AMPLIFY
# ============================================

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

# ============================================
# AMPLIFY APP PARA REACT + VITE
# ============================================

resource "aws_amplify_app" "react_app" {
  name                 = var.app_name
  repository           = var.github_repository
  platform             = "WEB"
  access_token         = var.github_token
  iam_service_role_arn = aws_iam_role.amplify_role.arn

  # Build spec optimizado para React + Vite
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - nvm install 20
            - nvm use 20
            - echo "🔍 Node version:"
            - node --version
            - npm --version
            - echo "📦 Installing dependencies..."
            - npm ci --legacy-peer-deps
        build:
          commands:
            - echo "🔨 Building React app with Vite..."
            - npx vite build
            - echo "✅ Build completed!"
            - echo "📂 Contents of dist:"
            - ls -la dist/
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

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
}

# ============================================
# OUTPUTS
# ============================================

output "amplify_app_id" {
  description = "ID de la aplicación Amplify"
  value       = aws_amplify_app.react_app.id
}

output "amplify_app_url" {
  description = "URL de la aplicación desplegada"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.react_app.default_domain}"
}

output "amplify_default_domain" {
  description = "Dominio por defecto de Amplify"
  value       = aws_amplify_app.react_app.default_domain
}

output "amplify_role_arn" {
  description = "ARN del rol IAM de Amplify"
  value       = aws_iam_role.amplify_role.arn
}

output "webhook_url" {
  description = "URL del webhook para disparar builds"
  value       = aws_amplify_webhook.main.url
  sensitive   = true
}

output "deployment_commands" {
  description = "Comandos útiles para deployment"
  value = <<-EOT

    🚀 DEPLOYMENT COMPLETADO
    ========================

    📍 URL de la app: https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.react_app.default_domain}

    🔧 Para ver logs:
       aws amplify list-jobs --app-id ${aws_amplify_app.react_app.id} --branch-name ${var.branch_name}

    🔄 Para forzar un nuevo build:
       aws amplify start-job --app-id ${aws_amplify_app.react_app.id} --branch-name ${var.branch_name} --job-type RELEASE

    📊 Monitorear en consola:
       https://console.aws.amazon.com/amplify/home?region=${data.aws_region.current.name}#/${aws_amplify_app.react_app.id}
  EOT
}