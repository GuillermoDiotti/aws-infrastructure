# ============================================
# API GATEWAY REST API
# ============================================

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-articles-api"
  description = "REST API for AI Articles"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-articles-api"
  }
}

# ============================================
# RESOURCES
# ============================================

resource "aws_api_gateway_resource" "articles" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "articles"
}

resource "aws_api_gateway_resource" "article_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.articles.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "comentarios" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "comentarios"
}

# ============================================
# GET /articles - Lista todos los artículos
# ============================================

resource "aws_api_gateway_method" "get_articles" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.articles.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_articles" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.get_articles.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_article_lambda_invoke_arn
}

# ============================================
# GET /articles/{id} - Obtiene un artículo específico
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

resource "aws_api_gateway_integration" "get_article_by_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.get_article_by_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_article_lambda_invoke_arn
}

# ============================================
# POST /articles - Generar nuevo artículo
# ============================================

resource "aws_api_gateway_method" "post_articles" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.articles.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_articles" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.articles.id
  http_method = aws_api_gateway_method.post_articles.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.generate_article_lambda_invoke_arn
}

# ============================================
# GET /comentarios - Lista comentarios
# ============================================

resource "aws_api_gateway_method" "get_comentarios" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.comentarios.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_comentarios" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.comentarios.id
  http_method = aws_api_gateway_method.get_comentarios.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_comentarios_lambda_invoke_arn
}

# ============================================
# POST /comentarios - Crear comentario
# ============================================

resource "aws_api_gateway_method" "post_comentarios" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.comentarios.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_comentarios" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.comentarios.id
  http_method = aws_api_gateway_method.post_comentarios.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.create_comentario_lambda_invoke_arn
}

# ============================================
# OPTIONS /comentarios (CORS)
# ============================================

resource "aws_api_gateway_method" "options_comentarios" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.comentarios.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_comentarios" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.comentarios.id
  http_method = aws_api_gateway_method.options_comentarios.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "options_comentarios_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.comentarios.id
  http_method = aws_api_gateway_method.options_comentarios.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_comentarios_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.comentarios.id
  http_method = aws_api_gateway_method.options_comentarios.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_comentarios]
}

# ============================================
# CORS - OPTIONS methods
# ============================================

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

# OPTIONS /articles/{id}
resource "aws_api_gateway_method" "options_article_id" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.article_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_article_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.options_article_id.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options_article_id_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.options_article_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_article_id_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.article_id.id
  http_method = aws_api_gateway_method.options_article_id.http_method
  status_code = aws_api_gateway_method_response.options_article_id_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_article_id]
}

# ============================================
# LAMBDA PERMISSIONS
# ============================================

resource "aws_lambda_permission" "api_gateway_get_article" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_article_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_generate_article" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.generate_article_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ============================================
# LAMBDA PERMISSIONS - Comentarios
# ============================================

resource "aws_lambda_permission" "api_gateway_get_comentarios" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_comentarios_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_create_comentario" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.create_comentario_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
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
      aws_api_gateway_resource.comentarios.id,
      aws_api_gateway_method.get_articles.id,
      aws_api_gateway_method.get_article_by_id.id,
      aws_api_gateway_method.post_articles.id,
      aws_api_gateway_method.get_comentarios.id,  # AGREGAR
      aws_api_gateway_method.post_comentarios.id, # AGREGAR
      aws_api_gateway_integration.get_articles.id,
      aws_api_gateway_integration.get_article_by_id.id,
      aws_api_gateway_integration.post_articles.id,
      aws_api_gateway_integration.get_comentarios.id,  # AGREGAR
      aws_api_gateway_integration.post_comentarios.id, # AGREGAR
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.get_articles,
    aws_api_gateway_integration.get_article_by_id,
    aws_api_gateway_integration.post_articles,
    aws_api_gateway_integration.get_comentarios,      # AGREGAR
    aws_api_gateway_integration.post_comentarios,
  ]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-api-stage-prod"
  }
}

# ============================================
# CLOUDWATCH LOGS
# ============================================

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-articles-api"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-api-gateway-logs"
  }
}