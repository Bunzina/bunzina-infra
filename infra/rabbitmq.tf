# Broker de mensageria da saga (ADR 0015): RabbitMQ de nó único, instalado por
# Helm a partir do chart local `charts/rabbitmq`, com a topologia (exchange topic
# `bunzina.events`, uma fila por serviço e DLQ por fila) carregada como definitions
# no boot. A topologia precisa bater com o `assertTopology` dos serviços; ver
# `charts/rabbitmq/values.yaml`.
#
# Chart próprio, e não o do Bitnami, porque as imagens `docker.io/bitnami/*`
# usadas por ele foram retiradas do Docker Hub; este usa a imagem oficial
# `rabbitmq:3.13-management`, a mesma do docker-compose dos serviços.
#
# Namespace próprio: o `bunzina-db` cria o namespace do PostgreSQL com
# `kubernetes_namespace_v1`, que falharia se este release o criasse antes.
#
# Endereço para os serviços (secret RABBITMQ_URL de cada repositório):
#   amqp://<usuario>:<senha>@bunzina-rabbitmq.rabbitmq.svc.cluster.local:5672

resource "helm_release" "rabbitmq" {
  name             = "bunzina-rabbitmq"
  chart            = "${path.module}/../charts/rabbitmq"
  namespace        = var.rabbitmq_namespace
  create_namespace = true

  set {
    name  = "auth.username"
    value = var.rabbitmq_username
  }

  set_sensitive {
    name  = "auth.password"
    value = var.rabbitmq_password
  }

  set {
    name  = "persistence.size"
    value = var.rabbitmq_storage_size
  }

  set {
    name  = "persistence.storageClass"
    value = var.rabbitmq_storage_class
  }

  wait    = true
  timeout = 300

  depends_on = [
    aws_eks_node_group.default,
    aws_eks_addon.ebs_csi,
  ]
}
