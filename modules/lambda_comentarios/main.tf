# ============================================
# DATA SOURCES
# ============================================

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ============================================
# LAMBDA LAYER - psycopg2
# ============================================

resource "aws_lambda_layer_version" "psycopg2" {
  filename            = "${path.module}/layers/psycopg2-layer.zip"
  layer_name          = "${var.project_name}-psycopg2-layer"
  compatible_runtimes = ["python3.12"]
  description         = "PostgreSQL adapter for Python"

  # El archivo debe ser creado manualmente o con un script
  # Ver: create_psycopg2_layer.sh
}

# ============================================
# LAMBDA: CREATE COMENTARIO
# ============================================

data "archive_file" "create_comentario" {
  type        = "zip"
  source_dir  = "${path.module}/functions/py/create_comentario"
  output_path = "${path.module}/functions/zip/lambda_create_comentario.zip"
}

resource "aws_lambda_function" "create_comentario" {
  filename      = data.archive_file.create_comentario.output_path
  function_name = "${var.project_name}-create-comentario"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  source_code_hash = data.archive_file.create_comentario.output_base64sha256

  layers = [aws_lambda_layer_version.psycopg2.arn]

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_credentials_secret_name
      REGION         = data.aws_region.current.name
    }
  }

  tags = {
    Name = "${var.project_name}-create-comentario"
  }
}

# ============================================
# LAMBDA: GET COMENTARIOS
# ============================================

data "archive_file" "get_comentarios" {
  type        = "zip"
  source_dir  = "${path.module}/functions/py/get_comentarios"
  output_path = "${path.module}/functions/zip/lambda_get_comentarios.zip"
}

resource "aws_lambda_function" "get_comentarios" {
  filename      = data.archive_file.get_comentarios.output_path
  function_name = "${var.project_name}-get-comentarios"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  source_code_hash = data.archive_file.get_comentarios.output_base64sha256

  layers = [aws_lambda_layer_version.psycopg2.arn]

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_credentials_secret_name
      REGION         = data.aws_region.current.name
    }
  }

  tags = {
    Name = "${var.project_name}-get-comentarios"
  }
}

# ============================================
# CLOUDWATCH LOG GROUPS
# ============================================

resource "aws_cloudwatch_log_group" "create_comentario" {
  name              = "/aws/lambda/${aws_lambda_function.create_comentario.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-create-comentario-logs"
  }
}

resource "aws_cloudwatch_log_group" "get_comentarios" {
  name              = "/aws/lambda/${aws_lambda_function.get_comentarios.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-get-comentarios-logs"
  }
}