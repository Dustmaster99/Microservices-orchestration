output "application_names" {
  description = "Lista de Applications criadas no ArgoCD."
  value       = keys(kubernetes_manifest.argocd_applications)
}