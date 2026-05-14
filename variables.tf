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

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "desired_node_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.micro"]
}
