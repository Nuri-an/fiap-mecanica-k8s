output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "internal_alb_arn" {
  value       = aws_lb.internal.arn
  description = "ARN of the internal Application Load Balancer"
}

output "backend_listener_arn" {
  value       = aws_lb_listener.internal_http.arn
  description = "ARN of the internal ALB listener for backend services"
}

output "eks_target_group_arn" {
  value       = aws_lb_target_group.eks_services.arn
  description = "ARN of the target group for EKS services"
}

output "internal_alb_security_group_id" {
  value       = aws_security_group.internal_alb.id
  description = "Security group ID for the internal ALB"
}
