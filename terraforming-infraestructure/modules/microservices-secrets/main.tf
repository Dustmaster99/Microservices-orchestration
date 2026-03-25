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
    AWS_SQS_URL        = var.sqs_url
    AWS_DYNAMODB_TABLE = var.analytics_dynamodb_table
    AWS_REGION         = var.aws_region
  }
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