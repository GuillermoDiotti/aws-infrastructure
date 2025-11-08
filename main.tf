module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

module "cloudtrail" {
  source = "./modules/cloudtrail_logging"

  project_name = var.project_name
}

module "cloudwatch_logging" {
  source = "./modules/cloudwatch_logging"

  project_name       = var.project_name
  log_retention_days = 30

  log_group_names = [
    # Lambda functions
    module.lambda_articulos.generate_article_log_group,
    module.lambda_articulos.get_article_log_group,
    module.lambda_comentarios.create_comentario_log_group,
    module.lambda_comentarios.get_comentarios_log_group,

    # API Gateway
    module.api_gateway.log_group_name,

    # Amplify
    module.amplify.amplify_log_group,

    # RDS
    module.rds.rds_log_group,

    # EventBridge
    module.eventbridge.eventbridge_log_group,

    # VPC Flow Logs
    module.networking.vpc_flow_log_group,

    # CloudTrail (DynamoDB, SNS, Secrets Manager, IAM)
    module.cloudtrail.cloudtrail_log_group,

    # SNS
  ]

  depends_on = [
    module.lambda_articulos,
    module.lambda_comentarios,
    module.api_gateway,
    module.amplify,
    module.rds,
    module.eventbridge,
    module.networking,
    module.cloudtrail
  ]
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch_alarms"

  project_name = var.project_name
  sns_topic_arn = module.sns.topic_arn

  lambda_functions = {
    generate_article    = module.lambda_articulos.generate_article_function_name
    get_article         = module.lambda_articulos.get_article_function_name
    create_comentario   = module.lambda_comentarios.create_comentario_function_name
    get_comentarios     = module.lambda_comentarios.get_comentarios_function_name
  }

  depends_on = [
    module.lambda_articulos,
    module.lambda_comentarios,
    module.sns
  ]
}

module "budget" {
  source = "./modules/budget"

  project_name         = var.project_name
  monthly_budget_limit = var.monthly_budget_limit
  notification_email   = var.notification_email
}

module "amplify" {
  source = "./modules/amplify"

  github_token      = var.github_token
  github_repository = var.github_repository
  app_name          = var.app_name
  branch_name       = var.branch_name
}

module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr   = var.private_subnet_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name                  = var.project_name
  enable_point_in_time_recovery = false
  enable_streams                = false
}

module "rds" {
  source = "./modules/rds"

  project_name               = var.project_name
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  lambda_security_group_id   = module.networking.lambda_security_group_id

  postgres_version      = "15.8"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  db_name               = "comentarios_db"
  db_username           = "dbadmin"

  skip_final_snapshot   = true
  deletion_protection   = false

  depends_on = [module.networking]
}

module "secrets_manager" {
  source = "./modules/secrets_manager"

  project_name       = var.project_name
  bedrock_model_id   = var.bedrock_model_id
  bedrock_temperature = 0.7
  bedrock_max_tokens = 2000

}

module "sns" {
  source = "./modules/sns"

  project_name        = var.project_name
  notification_email  = var.notification_email
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
  sns_topic_arn             = module.sns.topic_arn

  depends_on = [
    module.networking,
    module.dynamodb,
    module.secrets_manager,
    module.iam,
    module.sns

  ]
}

module "lambda_comentarios" {
  source = "./modules/lambda_comentarios"

  project_name                 = var.project_name
  lambda_role_arn              = module.iam.lambda_role_arn
  private_subnet_id            = module.networking.private_subnet_id
  lambda_security_group_id     = module.networking.lambda_security_group_id
  db_credentials_secret_name   = module.rds.db_credentials_secret_name
  comment_sns_topic_arn        = module.sns.comment_topic_arn  # ✅ AGREGAR ESTA LÍNEA

  depends_on = [
    module.networking,
    module.rds,
    module.iam,
    module.sns

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
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name = var.project_name

  get_article_lambda_function_name      = module.lambda_articulos.get_article_function_name
  get_article_lambda_invoke_arn         = module.lambda_articulos.get_article_invoke_arn
  generate_article_lambda_function_name = module.lambda_articulos.generate_article_function_name
  generate_article_lambda_invoke_arn    = module.lambda_articulos.generate_article_invoke_arn

  get_comentarios_lambda_function_name   = module.lambda_comentarios.get_comentarios_function_name
  get_comentarios_lambda_invoke_arn      = module.lambda_comentarios.get_comentarios_invoke_arn
  create_comentario_lambda_function_name = module.lambda_comentarios.create_comentario_function_name
  create_comentario_lambda_invoke_arn    = module.lambda_comentarios.create_comentario_invoke_arn

  depends_on = [
    module.networking,
    module.lambda_articulos,
    module.lambda_comentarios
  ]
}

module "static_site" {
  source = "./modules/static_site"

  project_name = var.project_name

  cache_default_ttl = var.static_site_cache_ttl
  cache_max_ttl     = var.static_site_cache_max_ttl

  tags = {
    Purpose = "institutional-website"
    Type    = "static"
  }
}