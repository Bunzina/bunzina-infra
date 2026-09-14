provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "bunzina"
      ManagedBy = "terraform"
    }
  }
}

# Autenticam contra o cluster que este mesmo state acabou de criar
# (aws_eks_cluster.this) usando um token de curta duração via `aws eks
# get-token` — sem depender de kubeconfig local nem de credenciais estáticas.
provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--region", var.aws_region]
    }
  }
}


