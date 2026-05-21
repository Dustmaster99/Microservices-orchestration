output "namespace" {
  description = "Namespace da stack de observabilidade."
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_service_name" {
  description = "Nome do Service do Grafana."
  value       = "${var.prometheus_release_name}-grafana"
}

output "grafana_service_type" {
  description = "Tipo do Service do Grafana."
  value       = var.grafana_service_type
}

output "grafana_namespace" {
  description = "Namespace onde o Grafana foi instalado."
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_persistence_enabled" {
  description = "Indica se a persistência do Grafana está habilitada."
  value       = var.grafana_persistence_enabled
}

output "grafana_persistence_size" {
  description = "Tamanho configurado para o PVC do Grafana."
  value       = var.grafana_persistence_size
}

output "prometheus_service_name" {
  description = "Nome do Service do Prometheus."
  value       = "${var.prometheus_release_name}-kube-prometheus-prometheus"
}

output "alertmanager_service_name" {
  description = "Nome do Service do Alertmanager."
  value       = "${var.prometheus_release_name}-kube-prometheus-alertmanager"
}

output "loki_service_name" {
  description = "Nome do Service do Loki."
  value       = var.loki_release_name
}

output "otel_collector_service_name" {
  description = "Nome do Service do OpenTelemetry Collector."
  value       = var.otel_collector_release_name
}

output "otel_collector_otlp_grpc_endpoint" {
  description = "Endpoint OTLP gRPC para os microsserviços."
  value       = "${var.otel_collector_release_name}.${var.namespace}.svc.cluster.local:4317"
}

output "otel_collector_otlp_http_endpoint" {
  description = "Endpoint OTLP HTTP para os microsserviços."
  value       = "http://${var.otel_collector_release_name}.${var.namespace}.svc.cluster.local:4318"
}

output "otel_collector_prometheus_scrape_endpoint" {
  description = "Endpoint onde o Prometheus coleta métricas exportadas pelo OTel."
  value       = "${var.otel_collector_release_name}.${var.namespace}.svc.cluster.local:8889"
}

output "datadog_secret_name" {
  description = "Nome do secret usado para integração com Datadog."
  value       = kubernetes_secret_v1.datadog.metadata[0].name
}