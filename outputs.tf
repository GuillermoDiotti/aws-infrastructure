/*output "amplify_app_id" {
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
*/

# ============================================
# NETWORKING OUTPUTS
# ============================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_id" {
  description = "Public Subnet ID (NAT Gateway aquí)"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "Private Subnet ID (Lambdas aquí)"
  value       = module.networking.private_subnet_id
}

output "lambda_security_group_id" {
  description = "Security Group para Lambdas"
  value       = module.networking.lambda_security_group_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.networking.nat_gateway_id
}

# ============================================
# API GATEWAY OUTPUTS
# ============================================

output "api_endpoint" {
  description = "API Gateway base URL"
  value       = module.api_gateway.api_endpoint
}

output "api_endpoints" {
  description = "API endpoints disponibles"
  value = {
    post_article   = "${module.api_gateway.api_endpoint}/articles"
    list_articles  = "${module.api_gateway.api_endpoint}/articles"
    get_article    = "${module.api_gateway.api_endpoint}/articles/{id}"
  }
}

# ============================================
# PHASE 1 STATUS
# ============================================

output "phase1_summary" {
  description = "Resumen de Phase 1"
  value = <<-EOT

    ✅ PHASE 1 COMPLETED: VPC + API Gateway
    ========================================

    🌐 VPC Configuration:
       VPC ID: ${module.networking.vpc_id}
       CIDR: ${module.networking.vpc_cidr}

       Public Subnet:  ${module.networking.public_subnet_id}
       Private Subnet: ${module.networking.private_subnet_id}

       NAT Gateway: ${module.networking.nat_gateway_id}
       Internet Gateway: ${module.networking.internet_gateway_id}

    🚪 API Gateway (Bridge):
       Base URL: ${module.api_gateway.api_endpoint}

       POST ${module.api_gateway.api_endpoint}/articles
       GET  ${module.api_gateway.api_endpoint}/articles
       GET  ${module.api_gateway.api_endpoint}/articles/{id}

    🧪 Test (Mock Response):
       curl ${module.api_gateway.api_endpoint}/articles
  EOT
}