
resource "kubernetes_manifest" "ingress_nginx_service_account" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "ingress-nginx"
      namespace = "ingress-nginx"
    }
  }

  depends_on = [kubernetes_manifest.ingress_nginx_namespace]
}

resource "kubernetes_manifest" "ingress_nginx_cluster_role" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "ingress-nginx"
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["configmaps", "endpoints", "nodes", "pods", "secrets", "services", "namespaces"]
        verbs     = ["get", "list", "watch"]
      },
      {
        apiGroups = [""]
        resources = ["events"]
        verbs     = ["create", "patch"]
      },
      {
        apiGroups = ["networking.k8s.io"]
        resources = ["ingresses", "ingressclasses"]
        verbs     = ["get", "list", "watch"]
      },
      {
        apiGroups = ["networking.k8s.io"]
        resources = ["ingresses/status"]
        verbs     = ["update"]
      },
      {
        apiGroups = ["discovery.k8s.io"]
        resources = ["endpointslices"]
        verbs     = ["get", "list", "watch"]
      }
    ]
  }

  depends_on = [kubernetes_manifest.ingress_nginx_namespace]
}

resource "kubernetes_manifest" "ingress_nginx_cluster_role_binding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "ingress-nginx"
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "ingress-nginx"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "ingress-nginx"
        namespace = "ingress-nginx"
      }
    ]
  }

  depends_on = [
    kubernetes_manifest.ingress_nginx_service_account,
    kubernetes_manifest.ingress_nginx_cluster_role
  ]
}

resource "kubernetes_manifest" "ingress_nginx_role" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "Role"
    metadata = {
      name      = "ingress-nginx"
      namespace = "ingress-nginx"
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["configmaps", "pods", "secrets", "endpoints"]
        verbs     = ["get"]
      },
      {
        apiGroups     = [""]
        resources     = ["configmaps"]
        resourceNames = ["ingress-nginx-controller"]
        verbs         = ["get", "update"]
      },
      {
        apiGroups = [""]
        resources = ["events"]
        verbs     = ["create", "patch"]
      },
      {
        apiGroups = ["coordination.k8s.io"]
        resources = ["leases"]
        verbs     = ["get", "create", "update"]
      }
    ]
  }

  depends_on = [kubernetes_manifest.ingress_nginx_namespace]
}

resource "kubernetes_manifest" "ingress_nginx_role_binding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"
    metadata = {
      name      = "ingress-nginx"
      namespace = "ingress-nginx"
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "Role"
      name     = "ingress-nginx"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "ingress-nginx"
        namespace = "ingress-nginx"
      }
    ]
  }

  depends_on = [
    kubernetes_manifest.ingress_nginx_service_account,
    kubernetes_manifest.ingress_nginx_role
  ]
}

resource "kubernetes_manifest" "ingress_nginx_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "ingress-nginx-controller"
      namespace = "ingress-nginx"
      annotations = {
        "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
        "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
      }
    }
    spec = {
      type = "LoadBalancer"
      selector = {
        "app.kubernetes.io/name" = "ingress-nginx"
      }
      ports = [
        {
          name       = "http"
          port       = 80
          targetPort = 80
          protocol   = "TCP"
        },
        {
          name       = "https"
          port       = 443
          targetPort = 443
          protocol   = "TCP"
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.ingress_nginx_namespace]
}

resource "kubernetes_manifest" "ingress_nginx_controller" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "ingress-nginx-controller"
      namespace = "ingress-nginx"
      labels = {
        "app.kubernetes.io/name" = "ingress-nginx"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "ingress-nginx"
        }
      }
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "ingress-nginx"
          }
        }
        spec = {
          serviceAccountName = "ingress-nginx"
          containers = [
            {
              name  = "controller"
              image = "registry.k8s.io/ingress-nginx/controller:v1.14.1"
              args = [
                "/nginx-ingress-controller",
                "--publish-service=$(POD_NAMESPACE)/ingress-nginx-controller",
                "--ingress-class=nginx"
              ]
              env = [
                {
                  name = "POD_NAME"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "metadata.name"
                    }
                  }
                },
                {
                  name = "POD_NAMESPACE"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "metadata.namespace"
                    }
                  }
                }
              ]
              ports = [
                {
                  containerPort = 80
                },
                {
                  containerPort = 443
                }
              ]
            }
          ]
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.ingress_nginx_service_account,
    kubernetes_manifest.ingress_nginx_cluster_role_binding,
    kubernetes_manifest.ingress_nginx_role_binding,
    kubernetes_manifest.ingress_nginx_service
  ]
}

resource "kubernetes_manifest" "ingress_nginx_class" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "IngressClass"

    metadata = {
      name = "nginx"
    }

    spec = {
      controller = "k8s.io/ingress-nginx"
    }
  }

  depends_on = [
    kubernetes_manifest.ingress_nginx_controller
  ]
}

resource "kubernetes_manifest" "evaluation_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"

    metadata = {
      name      = "evaluation-ingress"
      namespace = "fiap-microservices"
    }

    spec = {
      ingressClassName = "nginx"

      rules = [
        {
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"

                backend = {
                  service = {
                    name = "evaluation-service"

                    port = {
                      number = 8004
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.ingress_nginx_class
  ]
}