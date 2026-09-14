# bunzina-infra

Terraform configuration for the AWS infrastructure used by Bunzina.

## Scope

This repository provisions the shared platform resources:

- VPC with public and private subnets;
- EKS cluster and managed node group;
- EKS addons required by the cluster, including EBS CSI;
- ECR repositories for the application and Helm chart;
- networking and cluster access configuration.

The PostgreSQL workload is not provisioned here. It belongs to
[`bunzina-db`](https://github.com/Bunzina/bunzina-db), which creates the Kubernetes `gp3`
StorageClass, PostgreSQL workload, PVC, Secret, and Service after the EKS
cluster exists. The application deployment belongs to [`bunzina`](https://github.com/Bunzina/bunzina).

## Requirements

- Terraform >= 1.11
- AWS CLI configured with active AWS Academy credentials or another AWS identity
- An AWS region allowed by the account, normally `us-east-1` in the Learner Lab

AWS Academy credentials expire. Export all three temporary values in the same
terminal used by Terraform:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
export AWS_DEFAULT_REGION="us-east-1"
aws sts get-caller-identity
```

## Terraform state

The backend is configured at runtime through the S3 backend configuration. Use
one key for this repository and a different key for the database repository:

```text
bunzina/infra/dev/terraform.tfstate
bunzina/db/dev/terraform.tfstate
```

Keep the bucket private, enable versioning, and never commit state files,
credentials, or real `.tfvars` files.

## Deploy

From `infra/`:

```bash
terraform init -reconfigure \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=bunzina/infra/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform validate
terraform plan
terraform apply
```

After the cluster is active, configure access for Kubernetes:

```bash
aws eks update-kubeconfig --name bunzina-eks --region us-east-1
kubectl get nodes
```

Then apply `bunzina-db` before deploying the application. The database
repository reads the EKS cluster from this repository's remote state.

## Destroy

Destroy the database workload before destroying this infrastructure:

```bash
cd ../bunzina-db/infra
terraform destroy

cd ../../bunzina-infra/infra
terraform destroy
```

Destroying the database removes the PostgreSQL PVC and its EBS volume unless
the resource is deliberately preserved. Review the plan carefully, especially
when using a shared AWS Academy account.

## CI/CD

The Terraform workflow supports plan on pull requests and manual apply. It
requires these GitHub Secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

The AWS Academy session token must be updated whenever the lab credentials are
renewed. The workflow state key must remain distinct from the database state.