resource "aws_security_group" "vpc_link" {
  name        = "${var.project_name}-${var.environment}-apigw-vpc-link-sg"
  description = "Security group for API Gateway VPC Link ENIs"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-apigw-vpc-link-sg"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.project_name}-${var.environment}-vpc-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-link"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-http-api"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "private_backend" {
  api_id                 = aws_apigatewayv2_api.main.id
  connection_id          = aws_apigatewayv2_vpc_link.main.id
  connection_type        = "VPC_LINK"
  description            = "Private integration to internal load balancer listener"
  integration_method     = "ANY"
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.backend_listener_arn
  payload_format_version = "1.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_authorizer" "lambda" {
  count                             = var.lambda_authorizer_function_arn != "" ? 1 : 0
  api_id                            = aws_apigatewayv2_api.main.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.lambda_authorizer_function_arn
  authorizer_payload_format_version = var.lambda_authorizer_payload_format_version
  identity_sources                  = var.lambda_authorizer_identity_sources
  name                              = var.lambda_authorizer_name
}

resource "aws_lambda_permission" "authorizer_invoke" {
  count         = var.lambda_authorizer_function_arn != "" ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "auth_lambda" {
  count                  = var.auth_lambda_function_arn != "" ? 1 : 0
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.auth_lambda_function_arn}/invocations"
  payload_format_version = var.auth_lambda_payload_format_version
  description            = "Authentication Lambda integration for POST /auth"
}

resource "aws_lambda_permission" "auth_lambda_invoke" {
  count         = var.auth_lambda_function_arn != "" ? 1 : 0
  statement_id  = "AllowAPIGatewayInvokeAuth"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/POST/auth"
}

resource "aws_apigatewayv2_route" "auth" {
  count              = var.auth_lambda_function_arn != "" ? 1 : 0
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /auth"
  target             = "integrations/${aws_apigatewayv2_integration.auth_lambda[0].id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "default" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "$default"
  target             = "integrations/${aws_apigatewayv2_integration.private_backend.id}"
  authorization_type = length(aws_apigatewayv2_authorizer.lambda) > 0 ? "CUSTOM" : "NONE"
  authorizer_id      = length(aws_apigatewayv2_authorizer.lambda) > 0 ? aws_apigatewayv2_authorizer.lambda[0].id : null
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.api_gateway_stage_name
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 500
    throttling_rate_limit    = 1000
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.api_gateway_stage_name}"
    Environment = var.environment
  }
}
