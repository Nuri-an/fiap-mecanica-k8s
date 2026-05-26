variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fiap-mecanica"
}

variable "environment" {
  description = "Deployment environment (prod, hmg)"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Instance types for managed node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count"
  type        = number
  default     = 4
}

variable "api_backend_url" {
  description = "Public ALB URL (https://...) for API Gateway proxy integration"
  type        = string
  default     = ""
}

variable "auth_lambda_invoke_arn" {
  description = "Lambda invoke ARN for /auth/login integration"
  type        = string
  default     = ""
}

variable "jwt_secret" {
  description = "Secret key for JWT token signing"
  type        = string
  sensitive   = true
}

variable "enable_datadog" {
  description = "Whether to install Datadog agent via Helm"
  type        = bool
  default     = false
}

variable "datadog_api_key" {
  description = "Datadog API key (required if enable_datadog=true)"
  type        = string
  sensitive   = true
  default     = ""
}
