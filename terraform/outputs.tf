output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.app.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = module.app.ecr_repository_url
}
