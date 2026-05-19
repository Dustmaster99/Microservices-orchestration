variable "namespace" {
  description = "Namespace onde a stack de observabilidade será instalada."
  type        = string
  default     = "monitoring"
}

variable "prometheus_release_name" {
  description = "Nome do release Helm do kube-prometheus-stack."
  type        = string
  default     = "monitoring"
}

variable "loki_release_name" {
  description = "Nome do release Helm do Loki."
  type        = string
  default     = "loki"
}

variable "kube_prometheus_stack_chart_version" {
  description = "Versão do chart kube-prometheus-stack."
  type        = string
  default     = null
}

variable "loki_stack_chart_version" {
  description = "Versão do chart loki-stack."
  type        = string
  default     = null
}

variable "grafana_admin_user" {
  description = "Usuário administrador do Grafana."
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Senha administrador do Grafana."
  type        = string
  sensitive   = true
  default     = "root1234"
}

variable "grafana_service_type" {
  description = "Tipo do Service do Grafana."
  type        = string
  default     = "LoadBalancer"
}

variable "grafana_persistence_enabled" {
  description = "Habilita persistência para dashboards, datasources e configurações criadas no Grafana."
  type        = bool
  default     = true
}

variable "grafana_persistence_size" {
  description = "Tamanho do volume persistente do Grafana."
  type        = string
  default     = "5Gi"
}

variable "grafana_persistence_storage_class_name" {
  description = "StorageClass usada pelo PVC do Grafana. Em EKS, normalmente gp2 ou gp3. Use null para usar a StorageClass padrão do cluster."
  type        = string
  default     = null
}

variable "grafana_persistence_access_modes" {
  description = "Access modes do PVC do Grafana."
  type        = list(string)
  default     = ["ReadWriteOnce"]
}

variable "prometheus_retention" {
  description = "Tempo de retenção das métricas no Prometheus."
  type        = string
  default     = "7d"
}

variable "promtail_enabled" {
  description = "Mantém o Promtail ativo como fallback para logs. Para usar somente OTel, altere para false."
  type        = bool
  default     = true
}

variable "otel_collector_release_name" {
  description = "Nome do release Helm e do Service do OpenTelemetry Collector."
  type        = string
  default     = "otel-collector"
}

variable "otel_collector_chart_version" {
  description = "Versão do chart opentelemetry-collector."
  type        = string
  default     = null
}

variable "otel_collector_mode" {
  description = "Modo de instalação do OTel Collector: deployment, daemonset ou statefulset."
  type        = string
  default     = "deployment"
}

variable "loki_otlp_endpoint" {
  description = "Endpoint OTLP HTTP do Loki usado pelo OTel Collector."
  type        = string
  default     = "http://loki.monitoring.svc.cluster.local:3100/otlp"
}