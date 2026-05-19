variable "namespace" {
  description = "Namespace onde o ArgoCD será instalado."
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Nome da release Helm do ArgoCD."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Versão do chart Helm do ArgoCD."
  type        = string
}

variable "server_service_type" {
  description = "Tipo do service do ArgoCD server."
  type        = string
  default     = "LoadBalancer"
}

variable "timeout" {
  description = "Timeout da instalação Helm em segundos."
  type        = number
  default     = 900
}