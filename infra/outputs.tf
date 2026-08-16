output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_region" {
  value = var.aws_region
}

output "vpc_id" {
  description = "VPC ID (útil para instalar o AWS Load Balancer Controller)."
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "Repository URL for the application image in ECR"
  value       = aws_ecr_repository.bunzina.repository_url
}

output "ecr_chart_repository_url" {
  description = "Repository URL for the Helm chart in ECR"
  value       = aws_ecr_repository.bunzina_chart.repository_url
}

output "configure_kubectl" {
  description = "Command to configure kubectl with the EKS cluster context"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.aws_region}"
}