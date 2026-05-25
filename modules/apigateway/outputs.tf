output "api_gateway_id" {
  value = aws_apigatewayv2_api.main.id
}

output "api_gateway_endpoint" {
  value = aws_apigatewayv2_api.main.api_endpoint
}

output "api_gateway_stage_invoke_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
}

output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.main.execution_arn
}

output "api_gateway_authorizer_id" {
  value = length(aws_apigatewayv2_authorizer.lambda) > 0 ? aws_apigatewayv2_authorizer.lambda[0].id : null
}

output "vpc_link_id" {
  value = aws_apigatewayv2_vpc_link.main.id
}

output "vpc_link_security_group_id" {
  value = aws_security_group.vpc_link.id
}
