module "vpc" {
  source = "../../modules/vpc"

  project_name = "microservices"
  vpc_cidr     = var.vpc_cidr

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]

  database_subnets = [
    "10.0.30.0/24",
    "10.0.40.0/24"
  ]

  tags = {
    Project     = "microservices"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

module "analytics_dynamodb" {
  source = "../../modules/dynamodb"

  table_name    = "ToggleMasterAnalytics"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "id"
  hash_key_type = "S"

  tags = {
    Project = "fiap-microservices"
    Env     = "lab"
  }
}

module "rds" {
  source = "../../modules/rds"

  project_name        = "microservices"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  database_subnet_ids = module.vpc.database_subnet_ids

  db_instance_class = "db.t3.micro"

  auth_master_key      = var.auth_master_key
  flag_master_key      = var.flag_master_key
  targeting_master_key = var.targeting_master_key
  
  tags = {
    Project = "fiap-microservices"
    Env     = "lab"
  }
}

module "evaluation_response_sqs" {
  source = "../../modules/sqs"

  queue_name = "evaluation-service-response-sqs"

  tags = {
    Name    = "evaluation-service-response-sqs"
    Project = "fiap-microservices"
    Env     = "lab"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = "fiap-microservices"

  repositories = [
    "auth-service",
    "analytics-service",
    "evaluation-service",
    "flag-service",
    "targeting-service",
    "redis"
  ]

  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  tags = {
    Project     = "microservices"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "microservices-eks-cluster"
  cluster_version = "1.30"

  cluster_role_arn = "arn:aws:iam::657010996850:role/c208550a5300992l15128693t1w657010-LabEksClusterRole-kemEU9S0MoFv"
  node_role_arn    = "arn:aws:iam::657010996850:role/c208550a5300992l15128693t1w657010996-LabEksNodeRole-C4v3HFY4310Y"

  
  node_group_name    = "microservices-eks-nodes"
  private_subnet_ids = module.vpc.private_subnets

  instance_types = ["t3.medium"]
  capacity_type  = "SPOT"
  disk_size      = 20

  desired_size = 3
  min_size     = 2
  max_size     = 4

  max_unavailable = 1

  tags = {
    Project     = "microservices"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

module "cluster_manifests" {
  source = "../../modules/cluster-manifests"

  public_subnet_ids = module.vpc.public_subnets

  aws_access_key_id_secret     = var.aws_access_key_id_secret
  aws_secret_access_key_secret = var.aws_secret_access_key_secret
  aws_session_token_secret     = var.aws_session_token_secret

  depends_on = [module.eks]
}

module "microservices_secrets" {
  source = "../../modules/microservices-secrets"

  namespace = "fiap-microservices"
  aws_region = var.aws_region

  aws_access_key_id     = var.aws_access_key_id_secret
  aws_secret_access_key = var.aws_secret_access_key_secret
  aws_session_token     = var.aws_session_token_secret

  sqs_url                  = module.evaluation_response_sqs.queue_url
  analytics_dynamodb_table = module.analytics_dynamodb.table_name

  evaluation_service_api_key = var.evaluation_service_api_key

  auth_database_url      = module.rds.auth_database_url
  auth_master_key        = var.auth_master_key
  flag_database_url      = module.rds.flag_database_url
  targeting_database_url = module.rds.targeting_database_url

  analytics_service_port  = var.analytics_service_port
  evaluation_service_port = var.evaluation_service_port
  auth_service_port       = var.auth_service_port
  flag_service_port       = var.flag_service_port
  targeting_service_port  = var.targeting_service_port
  redis_service_port      = 6379

  redis_service_name     = "redis-service"
  auth_service_name      = var.auth_service_name
  flag_service_name      = var.flag_service_name
  targeting_service_name = var.targeting_service_name
}

module "argocd" {
  source = "../../modules/argocd"

  namespace           = module.cluster_manifests.argocd_namespace
  chart_version       = "7.8.2"
  server_service_type = "LoadBalancer"

  depends_on = [module.cluster_manifests]
}














