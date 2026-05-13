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
