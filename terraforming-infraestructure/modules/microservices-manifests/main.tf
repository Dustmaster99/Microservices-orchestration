locals {
  analytics_image  = "${var.ecr_registry}/analytics-service:${var.image_tag}"
  auth_image       = "${var.ecr_registry}/auth-service:${var.image_tag}"
  evaluation_image = "${var.ecr_registry}/evaluation-service:${var.image_tag}"
  flag_image       = "${var.ecr_registry}/flag-service:${var.image_tag}"
  targeting_image  = "${var.ecr_registry}/targeting-service:${var.image_tag}"
  redis_image      = "${var.ecr_registry}/redis:${var.image_tag}"
}

resource "kubernetes_manifest" "analytics_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "analytics-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      PORT               = "8005"
      AWS_SQS_URL        = var.analytics_aws_sqs_url
      AWS_DYNAMODB_TABLE = var.analytics_dynamodb_table
      AWS_REGION         = var.aws_region
    }
  }
}

resource "kubernetes_manifest" "analytics_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "analytics-service"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "analytics-service"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "analytics-service"
          }
        }
        spec = {
          containers = [
            {
              name  = "analytics-service"
              image = local.analytics_image
              ports = [
                {
                  containerPort = 8005
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = "analytics-secret"
                  }
                },
                {
                  secretRef = {
                    name = "aws-credentials"
                  }
                }
              ]
              resources = {
                requests = {
                  cpu = "100m"
                }
                limits = {
                  cpu = "500m"
                }
              }
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.analytics_secret]
}

resource "kubernetes_manifest" "analytics_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "analytics-service"
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = "analytics-service"
      }
      ports = [
        {
          port       = 8005
          targetPort = 8005
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.analytics_deployment]
}

resource "kubernetes_manifest" "analytics_hpa" {
  manifest = {
    apiVersion = "autoscaling/v2"
    kind       = "HorizontalPodAutoscaler"
    metadata = {
      name      = "analytics-hpa"
      namespace = var.namespace
    }
    spec = {
      scaleTargetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "analytics-service"
      }
      minReplicas = 1
      maxReplicas = 5
      metrics = [
        {
          type = "Resource"
          resource = {
            name = "cpu"
            target = {
              type               = "Utilization"
              averageUtilization = 70
            }
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.analytics_deployment]
}

resource "kubernetes_manifest" "auth_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "auth-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      DATABASE_URL = var.auth_database_url
      MASTER_KEY   = var.auth_master_key
      PORT         = "8001"
    }
  }
}

resource "kubernetes_manifest" "auth_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "auth-service"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "auth-service"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "auth-service"
          }
        }
        spec = {
          containers = [
            {
              name  = "auth-service"
              image = local.auth_image
              ports = [
                {
                  containerPort = 8001
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = "auth-secret"
                  }
                }
              ]
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.auth_secret]
}

resource "kubernetes_manifest" "auth_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "auth-service"
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = "auth-service"
      }
      ports = [
        {
          port       = 8001
          targetPort = 8001
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.auth_deployment]
}

resource "kubernetes_manifest" "flag_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "flag-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      DATABASE_URL     = var.flag_database_url
      PORT             = "8002"
      AUTH_SERVICE_URL = "http://auth-service:8001"
    }
  }
}

resource "kubernetes_manifest" "flag_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "flag-service"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "flag-service"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "flag-service"
          }
        }
        spec = {
          containers = [
            {
              name  = "flag-service"
              image = local.flag_image
              ports = [
                {
                  containerPort = 8002
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = "flag-secret"
                  }
                }
              ]
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.flag_secret]
}

resource "kubernetes_manifest" "flag_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "flag-service"
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = "flag-service"
      }
      ports = [
        {
          port       = 8002
          targetPort = 8002
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.flag_deployment]
}

resource "kubernetes_manifest" "targeting_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "targeting-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      DATABASE_URL     = var.targeting_database_url
      AUTH_SERVICE_URL = "http://auth-service:8001"
      PORT             = "8003"
    }
  }
}

resource "kubernetes_manifest" "targeting_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "targeting-service"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "targeting-service"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "targeting-service"
          }
        }
        spec = {
          containers = [
            {
              name  = "targeting-service"
              image = local.targeting_image
              ports = [
                {
                  containerPort = 8003
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = "targeting-secret"
                  }
                }
              ]
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.targeting_secret]
}

resource "kubernetes_manifest" "targeting_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "targeting-service"
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = "targeting-service"
      }
      ports = [
        {
          port       = 8003
          targetPort = 8003
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.targeting_deployment]
}

resource "kubernetes_manifest" "redis_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "redis-deployment"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "redis-server"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "redis-server"
          }
        }
        spec = {
          containers = [
            {
              name  = "redis-server"
              image = local.redis_image
              ports = [
                {
                  containerPort = 6379
                }
              ]
              command = [
                "redis-server",
                "--bind",
                "0.0.0.0"
              ]
              env = [
                {
                  name  = "REDIS_PORT"
                  value = "6379"
                }
              ]
            }
          ]
          restartPolicy = "Always"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "redis_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "redis-service"
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "redis-server"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = 6379
          targetPort = 6379
        }
      ]
      type = "ClusterIP"
    }
  }

  depends_on = [kubernetes_manifest.redis_deployment]
}

resource "kubernetes_manifest" "evaluation_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "evaluation-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      PORT                  = "8004"
      REDIS_URL             = "redis://redis-service:6379"
      FLAG_SERVICE_URL      = "http://flag-service:8002"
      TARGETING_SERVICE_URL = "http://targeting-service:8003"
      SERVICE_API_KEY       = var.evaluation_service_api_key
      AWS_REGION            = var.aws_region
      AWS_SQS_URL           = var.evaluation_aws_sqs_url
    }
  }
}

resource "kubernetes_manifest" "evaluation_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "evaluation-service"
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "evaluation-service"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "evaluation-service"
          }
        }
        spec = {
          containers = [
            {
              name  = "evaluation-service"
              image = local.evaluation_image
              ports = [
                {
                  containerPort = 8004
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = "evaluation-secret"
                  }
                },
                {
                  secretRef = {
                    name = "aws-credentials"
                  }
                }
              ]
              resources = {
                requests = {
                  cpu = "10m"
                }
                limits = {
                  cpu = "100m"
                }
              }
            }
          ]
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.evaluation_secret,
    kubernetes_manifest.redis_service,
    kubernetes_manifest.flag_service,
    kubernetes_manifest.targeting_service
  ]
}

resource "kubernetes_manifest" "evaluation_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "evaluation-service"
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = "evaluation-service"
      }
      ports = [
        {
          port       = 8004
          targetPort = 8004
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.evaluation_deployment]
}

resource "kubernetes_manifest" "evaluation_hpa" {
  manifest = {
    apiVersion = "autoscaling/v2"
    kind       = "HorizontalPodAutoscaler"
    metadata = {
      name      = "evaluation-hpa"
      namespace = var.namespace
    }
    spec = {
      scaleTargetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "evaluation-service"
      }
      minReplicas = 1
      maxReplicas = 5
      metrics = [
        {
          type = "Resource"
          resource = {
            name = "cpu"
            target = {
              type               = "Utilization"
              averageUtilization = 70
            }
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.evaluation_deployment]
}