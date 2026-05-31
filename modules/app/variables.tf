variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "api_backend_url" {
  description = "Public backend URL for API Gateway proxy integration"
  type        = string
}

variable "auth_lambda_invoke_arn" {
  description = "Lambda invoke ARN for authentication route"
  type        = string
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
}

variable "oidc_provider" {
  description = "OIDC provider URL for EKS IRSA"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for EKS IRSA"
  type        = string
}
