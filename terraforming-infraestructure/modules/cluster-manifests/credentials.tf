resource "kubernetes_secret_v1" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = "fiap-microservices"
  }

  type = "Opaque"

  data = {
    AWS_ACCESS_KEY_ID     = base64encode(var.aws_access_key_id_secret)
    AWS_SECRET_ACCESS_KEY = base64encode(var.aws_secret_access_key_secret)
    AWS_SESSION_TOKEN     = base64encode(var.aws_session_token_secret)
  }

  depends_on = [kubernetes_manifest.fiap_microservices_namespace]
}