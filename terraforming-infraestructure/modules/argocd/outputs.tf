output "release_name" {
  description = "Nome do release Helm do ArgoCD"
  value       = helm_release.argocd.name
}

output "namespace" {
  description = "Namespace onde o ArgoCD foi instalado"
  value       = var.namespace
}