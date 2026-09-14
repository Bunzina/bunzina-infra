# Add-ons que não têm um `aws_eks_addon` gerenciado equivalente (ou cujo
# equivalente gerenciado exige IRSA/Pod Identity) entram via Helm.
#
# AWS Academy Learner Lab não permite criar roles/policies IAM novas (só
# `LabRole`/`voclabs` já existentes) e não há OIDC provider no cluster — então
# IRSA e Pod Identity estão fora de alcance. O AWS Load Balancer Controller
# roda sob a role do nó (`LabRole`, já usada em `aws_eks_node_group.default`)
# via instance profile do EC2: por isso o `serviceAccount` abaixo não recebe
# nenhuma annotation de IRSA. Isso funciona porque o LabRole do curso já cobre
# as ações de ELBv2/EC2 necessárias; se um dia isso mudar, o sintoma é o
# controller subindo mas falhando ao criar o ALB (ver logs do pod).

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.lb_controller_chart_version
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  wait    = true
  timeout = 300

  depends_on = [aws_eks_node_group.default]
}

# Sem dependência de IAM: metrics-server só fala com os kubelets dentro do
# cluster. Alimenta o HPA por CPU do `app-chart` (ver `autoscaling.targetCPU`
# em charts/bunzina-chart/values.yaml).
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_chart_version
  namespace  = "kube-system"

  wait    = true
  timeout = 180

  depends_on = [aws_eks_node_group.default]
}
