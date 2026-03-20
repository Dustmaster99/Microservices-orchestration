terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ================================
# DATA SOURCES DO EKS
# ================================
data "aws_eks_cluster" "cluster_info" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

# ================================
# PROVIDER KUBERNETES
# ================================
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster_info.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster_info.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.cluster_auth.token
}

# ================================
# PROVIDER HELM
# ================================
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster_info.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster_info.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.cluster_auth.token
  }
}