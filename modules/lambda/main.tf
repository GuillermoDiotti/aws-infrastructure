# ============================================
# DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================
# IAM ROLE PARA LAMBDAS
# ============================================

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-articles-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-articles-role"
  }
}

# ============================================
# IAM POLICIES
# ============================================

# Policy para CloudWatch Logs
resource "aws_iam_role_policy" "lambda_logs" {
  name = "${var.project_name}-lambda-logs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-*"
      }
    ]
  })
}

# Policy para DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })
}

# Policy para Bedrock
resource "aws_iam_role_policy" "lambda_bedrock" {
  name = "${var.project_name}-lambda-bedrock-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
      }
    ]
  })
}

# Policy para VPC (necesario para Lambdas en VPC)
resource "aws_iam_role_policy" "lambda_vpc" {
  name = "${var.project_name}-lambda-vpc-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================
# LAMBDA FUNCTIONS
# ============================================

# Lambda: Generate Article (con Bedrock)
resource "aws_lambda_function" "generate_article" {
  filename      = "${path.module}/functions/zip/lambda_generate_article.zip"
  function_name = "${var.project_name}-generate-article"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 120  # 2 minutos (Bedrock puede tardar)
  memory_size   = 512

  source_code_hash = filebase64sha256("${path.module}/functions/zip/lambda_generate_article.zip")

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
  filename      = "${path.module}/functions/zip/lambda_get_article.zip"
  function_name = "${var.project_name}-get-article"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  source_code_hash = filebase64sha256("${path.module}/functions/zip/lambda_get_article.zip")

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