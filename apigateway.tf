resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-http"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["authorization", "content-type", "x-request-id"]
    allow_methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
  }

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 200
    throttling_rate_limit  = 100
  }
}

resource "aws_apigatewayv2_integration" "api_backend" {
  count                  = var.api_backend_url == "" ? 0 : 1
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.api_backend_url
  payload_format_version = "1.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "api_proxy" {
  count     = var.api_backend_url == "" ? 0 : 1
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.api_backend[0].id}"
}

resource "aws_apigatewayv2_integration" "auth_lambda" {
  count                  = var.auth_lambda_invoke_arn == "" ? 0 : 1
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.auth_lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_login" {
  count     = var.auth_lambda_invoke_arn == "" ? 0 : 1
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /auth/login"
  target    = "integrations/${aws_apigatewayv2_integration.auth_lambda[0].id}"
}
