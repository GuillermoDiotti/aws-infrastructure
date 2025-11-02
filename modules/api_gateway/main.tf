# ============================================
# API GATEWAY REST API
# ============================================
# REST API que actuará como puente público hacia la VPC privada

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-articles-api"
  description = "REST API for AI Articles - Bridge to VPC"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-articles-api"
  }
}

# ============================================
# RESOURCES (rutas)
# ============================================

# Resource: /articles
resource "aws_api_gateway_resource" "articles" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "articles"
}

# Resource: /articles/{id}
resource "aws_api_gateway_resource" "article_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.articles.id
  path_part   = "{id}"
}

# ============================================
# METHODS - POST /articles
# ============================================

resource "aws_api_gateway_method" "post_articles" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.articles.id
  http_method   = "POST"
  authorization = "NONE"
}

# Mock integration (temporal hasta que conectemos Lambda)
resource "aws_api_gateway_integration" "post_articles_mock" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.post_articles.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "post_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.post_articles.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "post_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.post_articles.http_method
  status_code = aws_api_gateway_method_response.post_articles_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "API Gateway configured - Lambda integration pending"
      status  = "mock_response"
    })
  }

  depends_on = [aws_api_gateway_integration.post_articles_mock]
}

# ============================================
# METHODS - GET /articles
# ============================================

resource "aws_api_gateway_method" "get_articles" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.articles.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_articles_mock" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.get_articles.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "get_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.get_articles.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.get_articles.http_method
  status_code = aws_api_gateway_method_response.get_articles_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = jsonencode({
      message  = "API Gateway configured - Lambda integration pending"
      articles = []
    })
  }

  depends_on = [aws_api_gateway_integration.get_articles_mock]
}

# ============================================
# METHODS - GET /articles/{id}
# ============================================

resource "aws_api_gateway_method" "get_article_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.article_id.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "get_article_by_id_mock" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.get_article_by_id.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "get_article_by_id_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.get_article_by_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_article_by_id_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.get_article_by_id.http_method
  status_code = aws_api_gateway_method_response.get_article_by_id_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "API Gateway configured - Lambda integration pending"
      id      = "$input.params('id')"
    })
  }

  depends_on = [aws_api_gateway_integration.get_article_by_id_mock]
}

# ============================================
# CORS - OPTIONS methods
# ============================================

# OPTIONS /articles
resource "aws_api_gateway_method" "options_articles" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.articles.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_articles" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.options_articles.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.options_articles.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_articles_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.options_articles.http_method
  status_code = aws_api_gateway_method_response.options_articles_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_articles]
}

# ============================================
# DEPLOYMENT
# ============================================

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.articles.id,
      aws_api_gateway_resource.article_id.id,
      aws_api_gateway_method.post_articles.id,
      aws_api_gateway_method.get_articles.id,
      aws_api_gateway_method.get_article_by_id.id,
      aws_api_gateway_integration.post_articles_mock.id,
      aws_api_gateway_integration.get_articles_mock.id,
      aws_api_gateway_integration.get_article_by_id_mock.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.post_articles_mock,
    aws_api_gateway_integration.get_articles_mock,
    aws_api_gateway_integration.get_article_by_id_mock,
    aws_api_gateway_integration_response.post_articles_200,
    aws_api_gateway_integration_response.get_articles_200,
    aws_api_gateway_integration_response.get_article_by_id_200,
  ]
}

# ============================================
# STAGE
# ============================================

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-api-stage-prod"
  }
}

# ============================================
# CLOUDWATCH LOGS (opcional)
# ============================================

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-articles-api"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-api-gateway-logs"
  }
}