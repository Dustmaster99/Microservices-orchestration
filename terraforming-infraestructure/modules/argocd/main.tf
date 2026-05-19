resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = false
  wait             = true

  values = [
    yamlencode({
      server = {
        service = {
          type = var.server_service_type
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "kubernetes_manifest" "argocd_applications" {
  for_each = var.argocd_applications

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }

    spec = {
      project = "default"

      source = {
        repoURL        = each.value.repo_url
        targetRevision = each.value.target_revision
        path           = each.value.path
      }

      destination = {
        server    = each.value.destination_server
        namespace = each.value.destination_namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }

        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}