resource "kubernetes_manifest" "argocd_applications" {
  for_each = var.argocd_applications

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = each.key
      namespace = var.argocd_namespace
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
}