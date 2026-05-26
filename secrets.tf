resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${var.project_name}/${var.environment}/jwt-secret"
  description = "JWT signing secret shared by API and auth Lambda"
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret
}
