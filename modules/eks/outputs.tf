output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "app_security_group" {
  value = aws_security_group.nodes.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
