variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fiap-mecanica"
}

variable "environment" {
  description = "Deployment environment (prod, hmg)"
  type        = string
  default     = "hmg"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "desired_node_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "tfc_organization" {
  description = "Terraform Cloud organization that hosts the shared infrastructure workspace"
  type        = string
}
variable "platform_workspace_name" {
  description = "Terraform Cloud workspace name for the shared platform or kubernetes infrastructure"
  type        = string
}

variable "api_gateway_stage_name" {
  description = "Nome do stage do API Gateway HTTP"
  type        = string
  default     = "$default"
}

variable "auth_lambda_function_arn" {
  description = "ARN of the authentication Lambda for the POST /auth route."
  type        = string
  default     = ""
}

variable "auth_lambda_payload_format_version" {
  description = "Payload format version used by the auth Lambda integration."
  type        = string
  default     = "2.0"
}

variable "lambda_authorizer_function_arn" {
  description = "Optional Lambda function ARN to use as an API Gateway HTTP authorizer."
  type        = string
  default     = ""
}

variable "lambda_authorizer_identity_sources" {
  description = "Identity sources for the Lambda authorizer request."
  type        = list(string)
  default     = ["$request.header.Authorization"]
}

variable "lambda_authorizer_payload_format_version" {
  description = "Lambda authorizer payload format version."
  type        = string
  default     = "2.0"
}

variable "lambda_authorizer_name" {
  description = "Authorizer name for the API Gateway HTTP API."
  type        = string
  default     = "http-api-lambda-authorizer"
}

