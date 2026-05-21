resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = var.prometheus_release_name
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_chart_version

  create_namespace = false
  timeout = 900
  wait    = true
  atomic  = false

  values = [
    yamlencode({
      grafana = {
        enabled = true

        adminUser     = var.grafana_admin_user
        adminPassword = var.grafana_admin_password

        service = {
          type = var.grafana_service_type
        }

        persistence = {
          enabled          = var.grafana_persistence_enabled
          type             = "pvc"
          size             = var.grafana_persistence_size
          storageClassName = var.grafana_persistence_storage_class_name
          accessModes      = var.grafana_persistence_access_modes
        }

        additionalDataSources = [
          {
            name      = "Loki"
            type      = "loki"
            access    = "proxy"
            url       = "http://${var.loki_release_name}.${var.namespace}.svc.cluster.local:3100"
            isDefault = false
          }
        ]
      }

      prometheus = {
        prometheusSpec = {
          retention = var.prometheus_retention

          additionalScrapeConfigs = [
            {
              job_name = "otel-collector"

              static_configs = [
                {
                  targets = [
                    "${var.otel_collector_release_name}.${var.namespace}.svc.cluster.local:8889"
                  ]
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "loki_stack" {
  name       = var.loki_release_name
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = var.loki_stack_chart_version

  create_namespace = false
  timeout = 900
  wait    = true
  atomic  = false

  values = [
    yamlencode({
      grafana = {
        enabled = false
      }

      promtail = {
        enabled = var.promtail_enabled
      }

      loki = {
        enabled = true

        persistence = {
          enabled = false
        }
      }
    })
  ]

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_secret_v1" "datadog" {
  metadata {
    name      = var.datadog_secret_name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    DD_API_KEY = var.datadog_api_key
  }

  type = "Opaque"
}

resource "helm_release" "otel_collector" {
  name       = var.otel_collector_release_name
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = var.otel_collector_chart_version

  create_namespace = false
  timeout          = 900
  wait             = true
  atomic           = false

  values = [
    yamlencode({
      fullnameOverride = var.otel_collector_release_name
      mode             = var.otel_collector_mode

      image = {
        repository = "otel/opentelemetry-collector-contrib"
      }

      service = {
        enabled = true
        type    = "ClusterIP"
      }

      extraEnvs = [
        {
          name = "DD_API_KEY"
          valueFrom = {
            secretKeyRef = {
              name = var.datadog_secret_name
              key  = "DD_API_KEY"
            }
          }
        }
      ]

      ports = {
        otlp = {
          enabled       = true
          containerPort = 4317
          servicePort   = 4317
          protocol      = "TCP"
        }

        otlp-http = {
          enabled       = true
          containerPort = 4318
          servicePort   = 4318
          protocol      = "TCP"
        }

        metrics = {
          enabled       = true
          containerPort = 8889
          servicePort   = 8889
          protocol      = "TCP"
        }
      }

      config = {
        receivers = {
          otlp = {
            protocols = {
              grpc = {
                endpoint = "0.0.0.0:4317"
              }

              http = {
                endpoint = "0.0.0.0:4318"
              }
            }
          }
        }

        processors = {
          memory_limiter = {
            check_interval         = "5s"
            limit_percentage       = 80
            spike_limit_percentage = 25
          }

          batch = {}
        }

        exporters = {
          prometheus = {
            endpoint = "0.0.0.0:8889"
          }

          datadog = {
            api = {
              key  = "$${env:DD_API_KEY}"
              site = var.datadog_site
            }
          }

          otlphttp = {
            endpoint = var.loki_otlp_endpoint

            tls = {
              insecure = true
            }
          }

          debug = {
            verbosity = "basic"
          }
        }

        service = {
          pipelines = {
            traces = {
              receivers  = ["otlp"]
              processors = ["memory_limiter", "batch"]
              exporters  = ["datadog", "debug"]
            }

            metrics = {
              receivers  = ["otlp"]
              processors = ["memory_limiter", "batch"]
              exporters  = ["prometheus", "datadog", "debug"]
            }

            logs = {
              receivers  = ["otlp"]
              processors = ["memory_limiter", "batch"]
              exporters  = ["otlphttp", "debug"]
            }
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.loki_stack,
    kubernetes_secret_v1.datadog
  ]
}