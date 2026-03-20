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

  tags = {
    Project     = "microservices"
    Environment = "lab"
    ManagedBy   = "Terraform"
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

  cluster_role_arn = "arn:aws:iam::654654184825:role/c204094a5205123l14214074t1w654654-LabEksClusterRole-YWV18Mvw5Znf"
  node_role_arn    = "arn:aws:iam::654654184825:role/c204094a5205123l14214074t1w654654184-LabEksNodeRole-68tJGgiNWax2"

  node_group_name    = "microservices-eks-nodes"
  private_subnet_ids = module.vpc.private_subnets

  instance_types = ["t3.small"]
  capacity_type  = "SPOT"
  disk_size      = 20

  desired_size = 2
  min_size     = 1
  max_size     = 3

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

module "microservices_manifests" {
  source = "../../modules/microservices-manifests"

  namespace = "fiap-microservices"
  aws_region = var.aws_region
  ecr_registry = "760729969288.dkr.ecr.us-east-1.amazonaws.com/fiap-microservices"
  image_tag = "latest"

  analytics_aws_sqs_url     = "https://sqs.us-east-1.amazonaws.com/760729969288/evaluation-service-response-sqs"
  analytics_dynamodb_table  = "ToggleMasterAnalytics"
  auth_database_url         = var.auth_database_url
  auth_master_key           = var.auth_master_key
  flag_database_url         = var.flag_database_url
  targeting_database_url    = var.targeting_database_url
  evaluation_service_api_key = var.evaluation_service_api_key
  evaluation_aws_sqs_url    = "https://sqs.us-east-1.amazonaws.com/760729969288/evaluation-service-response-sqs"

  depends_on = [module.cluster_manifests]
}