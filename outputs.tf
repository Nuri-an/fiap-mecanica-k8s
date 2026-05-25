output "ecr_repository_url" {
  description = "ECR repository URL for the Kubernetes application image"
  value       = module.eks.ecr_repository_url
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for load balancers and public resources"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes and managed databases"
  value       = module.networking.private_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "app_security_group" {
  description = "Security group used by Kubernetes worker nodes to access the database"
  value       = module.eks.app_security_group
}

output "api_gateway_id" {
  description = "HTTP API Gateway identifier"
  value       = module.apigateway.api_gateway_id
}

output "api_gateway_endpoint" {
  description = "Public endpoint for the API Gateway"
  value       = module.apigateway.api_gateway_endpoint
}

output "internal_alb_arn" {
  description = "ARN of the internal Application Load Balancer"
  value       = module.networking.internal_alb_arn
}

output "backend_listener_arn" {
  description = "ARN of the internal ALB listener for backend services"
  value       = module.networking.backend_listener_arn
}

output "eks_target_group_arn" {
  description = "ARN of the target group for EKS services"
  value       = module.networking.eks_target_group_arn
}

output "api_gateway_stage_invoke_url" {
  description = "Invoke URL for the configured API Gateway stage"
  value       = module.apigateway.api_gateway_stage_invoke_url
}

output "api_gateway_execution_arn" {
  description = "Execution ARN for the API Gateway"
  value       = module.apigateway.api_gateway_execution_arn
}

output "vpc_link_id" {
  description = "API Gateway VPC Link identifier"
  value       = module.apigateway.vpc_link_id
}

output "vpc_link_security_group_id" {
  description = "Security group attached to the API Gateway VPC Link ENIs"
  value       = module.apigateway.vpc_link_security_group_id
}
