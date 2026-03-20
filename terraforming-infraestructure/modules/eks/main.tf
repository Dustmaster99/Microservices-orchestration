resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "AL2_x86_64"
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  tags = merge(
    {
      Name = var.node_group_name
    },
    var.tags
  )

  depends_on   = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "node_monitoring" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-node-monitoring-agent"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.eks_cluster]
}

