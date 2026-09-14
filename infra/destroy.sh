#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo ">> Conferindo credenciais do Learner Lab..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "!! Credenciais inválidas/expiradas. Renove em AWS Details -> AWS CLI e tente de novo."
  exit 1
fi

echo ">> Destruindo toda a infra (EKS, node group, VPC, NAT, ECR...)."
terraform destroy -auto-approve
echo ">> Pronto. Recursos derrubados, relógio de custo parado."
