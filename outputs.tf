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