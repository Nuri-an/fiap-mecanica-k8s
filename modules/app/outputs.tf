output "ecr_repository_url" {
  description = "ECR repository URL for API images"
  value       = aws_ecr_repository.api.repository_url
}

output "jwt_secret_arn" {
  description = "JWT secret ARN in Secrets Manager"
  value       = aws_secretsmanager_secret.jwt_secret.arn
  sensitive   = true
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permissions"
  value       = aws_apigatewayv2_api.main.execution_arn
}
