variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "backend_listener_arn" {
  type = string
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

variable "auth_lambda_function_arn" {
  description = "Optional ARN of the authentication Lambda for the POST /auth route."
  type        = string
  default     = ""
}

variable "auth_lambda_payload_format_version" {
  description = "Payload format version used by the auth Lambda integration."
  type        = string
  default     = "2.0"
}

variable "aws_region" {
  description = "AWS region used to build Lambda integration URIs."
  type        = string
}

variable "api_gateway_stage_name" {
  type = string
}
