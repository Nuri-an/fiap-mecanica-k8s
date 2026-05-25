variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "desired_node_count" {
  type = number
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}

variable "node_instance_types" {
  type = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "internal_alb_arn" {
  description = "ARN of the internal ALB for EKS services"
  type        = string
}

variable "eks_target_group_arn" {
  description = "ARN of the target group for EKS services"
  type        = string
}
