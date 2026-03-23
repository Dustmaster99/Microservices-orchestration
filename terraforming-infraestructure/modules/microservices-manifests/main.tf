locals {
  analytics_image  = "${var.ecr_registry}/analytics-service:${var.image_tag}"
  auth_image       = "${var.ecr_registry}/auth-service:${var.image_tag}"
  evaluation_image = "${var.ecr_registry}/evaluation-service:${var.image_tag}"
  flag_image       = "${var.ecr_registry}/flag-service:${var.image_tag}"
  targeting_image  = "${var.ecr_registry}/targeting-service:${var.image_tag}"
  redis_image = "${var.ecr_registry}/redis:${var.image_tag_redis}"
}

resource "kubernetes_secret_v1" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_SESSION_TOKEN     = var.aws_session_token
  }
}

resource "kubernetes_secret_v1" "analytics_secret" {
  metadata {
    name      = "analytics-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    PORT               = tostring(var.analytics_service_port)
    AWS_SQS_URL = var.sqs_url
    AWS_DYNAMODB_TABLE = var.analytics_dynamodb_table
    AWS_REGION         = var.aws_region
  }
}

resource "kubernetes_manifest" "analytics_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.analytics_service_name
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.analytics_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.analytics_service_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.analytics_service_name
              image = local.analytics_image
              ports = [
                {
                  containerPort = var.analytics_service_port
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

  depends_on = [
    kubernetes_secret_v1.analytics_secret,
    kubernetes_secret_v1.aws_credentials
  ]
}

resource "kubernetes_manifest" "analytics_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.analytics_service_name
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = var.analytics_service_name
      }
      ports = [
        {
          port       = var.analytics_service_port
          targetPort = var.analytics_service_port
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
        name       = var.analytics_service_name
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

resource "kubernetes_secret_v1" "auth_secret" {
  metadata {
    name      = "auth-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    DATABASE_URL = var.auth_database_url
    MASTER_KEY   = var.auth_master_key
    PORT         = tostring(var.auth_service_port)
  }
}

resource "kubernetes_manifest" "auth_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.auth_service_name
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.auth_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.auth_service_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.auth_service_name
              image = local.auth_image
              ports = [
                {
                  containerPort = var.auth_service_port
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

  depends_on = [kubernetes_secret_v1.auth_secret]
}

resource "kubernetes_manifest" "auth_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.auth_service_name
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = var.auth_service_name
      }
      ports = [
        {
          port       = var.auth_service_port
          targetPort = var.auth_service_port
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.auth_deployment]
}

resource "kubernetes_secret_v1" "flag_secret" {
  metadata {
    name      = "flag-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    DATABASE_URL     = var.flag_database_url
    PORT             = tostring(var.flag_service_port)
    AUTH_SERVICE_URL = "http://${var.auth_service_name}:${var.auth_service_port}"
  }
}

resource "kubernetes_manifest" "flag_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.flag_service_name
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.flag_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.flag_service_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.flag_service_name
              image = local.flag_image
              ports = [
                {
                  containerPort = var.flag_service_port
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

  depends_on = [
    kubernetes_secret_v1.flag_secret,
    kubernetes_manifest.auth_service
  ]
}

resource "kubernetes_manifest" "flag_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.flag_service_name
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = var.flag_service_name
      }
      ports = [
        {
          port       = var.flag_service_port
          targetPort = var.flag_service_port
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.flag_deployment]
}

resource "kubernetes_secret_v1" "targeting_secret" {
  metadata {
    name      = "targeting-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    DATABASE_URL     = var.targeting_database_url
    AUTH_SERVICE_URL = "http://${var.auth_service_name}:${var.auth_service_port}"
    PORT             = tostring(var.targeting_service_port)
  }
}

resource "kubernetes_manifest" "targeting_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.targeting_service_name
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.targeting_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.targeting_service_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.targeting_service_name
              image = local.targeting_image
              ports = [
                {
                  containerPort = var.targeting_service_port
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

  depends_on = [
    kubernetes_secret_v1.targeting_secret,
    kubernetes_manifest.auth_service
  ]
}

resource "kubernetes_manifest" "targeting_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.targeting_service_name
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = var.targeting_service_name
      }
      ports = [
        {
          port       = var.targeting_service_port
          targetPort = var.targeting_service_port
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
                  containerPort = var.redis_port
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
                  value = tostring(var.redis_port)
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
      name      = var.redis_service_name
      namespace = var.namespace
    }
    spec = {
      selector = {
        app = "redis-server"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = var.redis_service_port
          targetPort = var.redis_port
        }
      ]
      type = "ClusterIP"
    }
  }

  depends_on = [kubernetes_manifest.redis_deployment]
}

resource "kubernetes_secret_v1" "evaluation_secret" {
  metadata {
    name      = "evaluation-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    PORT                  = tostring(var.evaluation_service_port)
    REDIS_URL             = "redis://${var.redis_service_name}:${var.redis_service_port}"
    FLAG_SERVICE_URL      = "http://${var.flag_service_name}:${var.flag_service_port}"
    TARGETING_SERVICE_URL = "http://${var.targeting_service_name}:${var.targeting_service_port}"
    SERVICE_API_KEY       = var.evaluation_service_api_key
    AWS_REGION            = var.aws_region
    AWS_SQS_URL           = var.sqs_url
  }
}

resource "kubernetes_manifest" "evaluation_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.evaluation_service_name
      namespace = var.namespace
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.evaluation_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.evaluation_service_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.evaluation_service_name
              image = local.evaluation_image
              ports = [
                {
                  containerPort = var.evaluation_service_port
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
    kubernetes_secret_v1.evaluation_secret,
    kubernetes_secret_v1.aws_credentials,
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
      name      = var.evaluation_service_name
      namespace = var.namespace
    }
    spec = {
      type = "ClusterIP"
      selector = {
        app = var.evaluation_service_name
      }
      ports = [
        {
          port       = var.evaluation_service_port
          targetPort = var.evaluation_service_port
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
        name       = var.evaluation_service_name
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