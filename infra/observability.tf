# Stack de observabilidade da plataforma (Prometheus, Grafana, Loki, Tempo, Alloy).
# Fica aqui, e não no deploy de um serviço, porque traz as CRDs do Prometheus
# Operator (`ServiceMonitor`, ...) de que os charts dos serviços dependem, e o
# endpoint OTLP (`alloy-gateway`) e o SMTP (`mailcatcher`) que eles usam.
#
# O chart usa a StorageClass `gp2`, que o EKS já traz: a `gp3` é criada pelo
# bunzina-db, que roda depois desta infra.

resource "random_password" "grafana_admin" {
  length  = 24
  special = false
}

resource "helm_release" "observability" {
  name             = "bunzina-observability"
  chart            = "${path.module}/../charts/bunzina-observability"
  namespace        = "observability"
  create_namespace = true

  dependency_update = true

  set_sensitive {
    name  = "kube-prometheus-stack.grafana.adminPassword"
    value = random_password.grafana_admin.result
  }

  # O provider não percebe mudança em templates e dashboards de um chart local:
  # este hash muda o release quando eles mudam.
  set {
    name = "contentHash"
    value = sha1(join("", [
      for f in sort(fileset("${path.module}/../charts/bunzina-observability", "{templates,dashboards}/*")) :
      filesha1("${path.module}/../charts/bunzina-observability/${f}")
    ]))
  }

  wait    = true
  timeout = 900

  depends_on = [
    aws_eks_node_group.default,
    aws_eks_addon.ebs_csi,
    helm_release.aws_load_balancer_controller,
  ]
}
