variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fiap-mecanica"
}

variable "environment" {
  description = "Deployment environment (production, staging)"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "docker_image" {
  description = "Docker image URI for the application (e.g. ghcr.io/user/fiap-mecanica:latest)"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  default     = "fiapmecanica"
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secret key for JWT token signing"
  type        = string
  sensitive   = true
}
