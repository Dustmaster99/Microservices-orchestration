variable "namespace" {
  description = "Namespace onde o ArgoCD será instalado"
  type        = string
}

variable "chart_version" {
  description = "Versão do chart argo-cd"
  type        = string
  default     = "7.8.2"
}

variable "server_service_type" {
  description = "Tipo do service do argocd-server"
  type        = string
  default     = "LoadBalancer"
}