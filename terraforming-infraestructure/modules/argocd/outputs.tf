output "namespace" {
  description = "Namespace onde o ArgoCD foi instalado."
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "server_service_type" {
  description = "Tipo do Service do ArgoCD Server."
  value       = var.server_service_type
}

output "applications" {
  description = "Aplicações criadas automaticamente no ArgoCD."
  value       = keys(var.argocd_applications)
}