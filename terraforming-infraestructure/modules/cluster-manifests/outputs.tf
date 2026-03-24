output "argocd_namespace" {
  description = "Nome do namespace do ArgoCD"
  value       = kubernetes_manifest.argocd_namespace.manifest.metadata.name
}