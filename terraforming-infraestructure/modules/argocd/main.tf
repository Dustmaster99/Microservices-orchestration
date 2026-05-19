resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name             = var.release_name
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = false

  wait    = true
  timeout = var.timeout

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