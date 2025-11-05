# ============================================
# PHASE 1: VPC + API Gateway (Bridge to VPC)
# ============================================

module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

module "amplify" {
  source = "./modules/amplify"

  github_token      = var.github_token
  github_repository = var.github_repository
  app_name          = var.app_name
  branch_name       = var.branch_name
}

# Networking Module - VPC con subnets públicas y privadas
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name                  = var.project_name
  enable_point_in_time_recovery = false
  enable_streams                = false
}

module "secrets_manager" {
  source = "./modules/secrets_manager"

  project_name       = var.project_name
  bedrock_model_id   = var.bedrock_model_id
  bedrock_temperature = 0.7
  bedrock_max_tokens = 2000

}

module "lambda_articulos" {
  source = "./modules/lambda_articulos"

  project_name              = var.project_name
  dynamodb_table_name       = module.dynamodb.table_name
  dynamodb_table_arn        = module.dynamodb.table_arn
  private_subnet_id         = module.networking.private_subnet_id
  lambda_security_group_id  = module.networking.lambda_security_group_id
  bedrock_secret_name       = module.secrets_manager.bedrock_config_secret_name
  lambda_role_arn           = module.iam.lambda_role_arn


  depends_on = [
    module.networking,
    module.dynamodb,
    module.secrets_manager,
    module.iam

  ]
}

module "eventbridge" {
  source = "./modules/eventbridge"

  project_name         = var.project_name
  schedule_expression  = var.article_generation_schedule
  lambda_function_name = module.lambda_articulos.generate_article_function_name  # CORREGIR
  lambda_function_arn  = module.lambda_articulos.generate_article_function_arn   # CORREGIR

  depends_on = [module.lambda_articulos]
}

# API Gateway Module - REST API como puente público
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name = var.project_name

  # Conectar Lambdas
  get_article_lambda_function_name      = module.lambda_articulos.get_article_function_name
  get_article_lambda_invoke_arn         = module.lambda_articulos.get_article_invoke_arn
  generate_article_lambda_function_name = module.lambda_articulos.generate_article_function_name
  generate_article_lambda_invoke_arn    = module.lambda_articulos.generate_article_invoke_arn

  depends_on = [module.networking, module.lambda_articulos]
}