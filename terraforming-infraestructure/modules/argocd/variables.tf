variable "namespace" {
  description = "Namespace onde o ArgoCD será instalado."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Versão do Helm chart do ArgoCD."
  type        = string
  default     = "7.6.12"
}

variable "server_service_type" {
  description = "Tipo do Service do ArgoCD Server."
  type        = string
  default     = "LoadBalancer"
}

variable "argocd_applications" {
  description = "Aplicações que serão criadas automaticamente no ArgoCD."
  type = map(object({
    repo_url              = string
    target_revision       = string
    path                  = string
    destination_server    = string
    destination_namespace = string
  }))

  default = {}
}