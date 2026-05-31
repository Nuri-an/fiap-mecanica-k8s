output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "Node security group ID"
  value       = module.eks.node_security_group_id
}

output "app_security_group" {
  description = "Security group for app access (use in RDS ingress)"
  value       = module.eks.node_security_group_id
}

output "ecr_repository_url" {
  description = "ECR repository URL for API images"
  value       = module.app.ecr_repository_url
}

output "jwt_secret_arn" {
  description = "JWT secret ARN in Secrets Manager"
  value       = module.app.jwt_secret_arn
  sensitive   = true
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.app.api_gateway_url
}

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permissions"
  value       = module.app.api_gateway_execution_arn
}
