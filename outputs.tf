# outputs.tf - CORREGIR
output "deployment_commands" {
  description = "Comandos útiles para deployment"
  value = <<-EOT

    🚀 DEPLOYMENT COMPLETADO
    ========================

    📍 URL de la app: ${module.amplify.amplify_app_url}

    🔧 Para ver logs:
       aws amplify list-jobs --app-id ${module.amplify.amplify_app_id} --branch-name ${module.amplify.branch_name}

    🔄 Para forzar un nuevo build:
       aws amplify start-job --app-id ${module.amplify.amplify_app_id} --branch-name ${module.amplify.branch_name} --job-type RELEASE

    📊 Monitorear en consola:
       https://console.aws.amazon.com/amplify/home?region=${data.aws_region.current.name}#/${module.amplify.amplify_app_id}
  EOT
}

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