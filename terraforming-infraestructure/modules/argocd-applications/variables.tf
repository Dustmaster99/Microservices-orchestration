variable "argocd_namespace" {
  description = "Namespace onde o ArgoCD está instalado."
  type        = string
  default     = "argocd"
}

variable "argocd_applications" {
  description = "Mapa de aplicações ArgoCD a serem criadas."
  type = map(object({
    repo_url              = string
    target_revision       = string
    path                  = string
    destination_server    = string
    destination_namespace = string
  }))
}