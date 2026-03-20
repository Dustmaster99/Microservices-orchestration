resource "kubernetes_manifest" "fiap_microservices_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "fiap-microservices"
    }
  }
}

resource "kubernetes_manifest" "ingress_nginx_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "ingress-nginx"
    }
  }
}