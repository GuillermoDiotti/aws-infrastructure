# ============================================
# LAMBDA FUNCTIONS
# ============================================

# Lambda: Generate Article (con Bedrock)
resource "aws_lambda_function" "generate_article" {
  filename      = data.archive_file.generate_article.output_path
  function_name = "${var.project_name}-generate-article"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 120  # 2 minutos (Bedrock puede tardar)
  memory_size   = 512

  source_code_hash = data.archive_file.generate_article.output_base64sha256

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      REGION         = data.aws_region.current.name
    }
  }

  tags = {
    Name = "${var.project_name}-generate-article"
  }
}

# Lambda: Get Article (consultas a DynamoDB)
resource "aws_lambda_function" "get_article" {
  filename      = data.archive_file.get_article.output_path
  function_name = "${var.project_name}-get-article"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  source_code_hash = data.archive_file.get_article.output_base64sha256

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      REGION         = data.aws_region.current.name
    }
  }

  tags = {
    Name = "${var.project_name}-get-article"
  }
}

# ============================================
# CLOUDWATCH LOG GROUPS
# ============================================

resource "aws_cloudwatch_log_group" "generate_article" {
  name              = "/aws/lambda/${aws_lambda_function.generate_article.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-generate-article-logs"
  }
}

resource "aws_cloudwatch_log_group" "get_article" {
  name              = "/aws/lambda/${aws_lambda_function.get_article.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-get-article-logs"
  }
}