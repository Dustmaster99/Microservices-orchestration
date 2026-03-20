output "cluster_id" {
  description = "ID do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint privado do cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificado da autoridade certificadora do cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "node_group_arn" {
  description = "ARN do node group"
  value       = aws_eks_node_group.eks_node_group.arn
}

output "node_group_status" {
  description = "Status do node group"
  value       = aws_eks_node_group.eks_node_group.status
}