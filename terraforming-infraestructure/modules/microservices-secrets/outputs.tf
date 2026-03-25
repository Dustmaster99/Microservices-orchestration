output "aws_credentials_secret_name" {
  description = "Nome do secret com credenciais AWS"
  value       = kubernetes_secret_v1.aws_credentials.metadata[0].name
}

output "analytics_secret_name" {
  description = "Nome do secret do analytics-service"
  value       = kubernetes_secret_v1.analytics_secret.metadata[0].name
}

output "evaluation_secret_name" {
  description = "Nome do secret do evaluation-service"
  value       = kubernetes_secret_v1.evaluation_secret.metadata[0].name
}

output "auth_secret_name" {
  description = "Nome do secret do auth-service"
  value       = kubernetes_secret_v1.auth_secret.metadata[0].name
}

output "flag_secret_name" {
  description = "Nome do secret do flag-service"
  value       = kubernetes_secret_v1.flag_secret.metadata[0].name
}

output "targeting_secret_name" {
  description = "Nome do secret do targeting-service"
  value       = kubernetes_secret_v1.targeting_secret.metadata[0].name
}