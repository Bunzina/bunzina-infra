variable "aws_region" {
  description = "AWS region to deploy resources in. NOTE: the AWS Academy Learner Lab only permits us-east-1 (and a few US/EU regions); sa-east-1 is denied."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "bunzina"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "List of EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in the EKS cluster"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes in the EKS cluster"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes in the EKS cluster"
  type        = number
  default     = 4
}

variable "lb_controller_chart_version" {
  description = "Chart version for the AWS Load Balancer Controller (aws.github.io/eks-charts)"
  type        = string
  default     = "3.5.0"
}

variable "metrics_server_chart_version" {
  description = "Chart version for metrics-server (kubernetes-sigs.github.io/metrics-server)"
  type        = string
  default     = "3.14.0"
}

variable "rabbitmq_namespace" {
  description = "Kubernetes namespace do RabbitMQ. Deve diferir do namespace criado pelo bunzina-db."
  type        = string
  default     = "rabbitmq"
}

variable "rabbitmq_username" {
  description = "Usuário administrador do RabbitMQ usado pelos serviços."
  type        = string
  default     = "bunzina"
}

variable "rabbitmq_password" {
  description = "Senha do usuário do RabbitMQ. Sem default: vem de TF_VAR_rabbitmq_password (secret RABBITMQ_PASSWORD no GitHub Actions). A mesma senha vai na URL do secret RABBITMQ_URL de cada serviço."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.rabbitmq_password) >= 8
    error_message = "rabbitmq_password precisa ter ao menos 8 caracteres (defina TF_VAR_rabbitmq_password)."
  }
}

variable "rabbitmq_storage_size" {
  description = "Tamanho do volume do RabbitMQ."
  type        = string
  default     = "2Gi"
}

variable "rabbitmq_storage_class" {
  description = "StorageClass do volume do RabbitMQ. Vazio usa a padrão do cluster (a gp3 é criada depois, pelo bunzina-db)."
  type        = string
  default     = ""
}
