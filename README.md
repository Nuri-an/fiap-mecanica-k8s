# fiap-mecanica-k8s — Kubernetes Platform (Infrastructure)

This repository contains the Terraform infrastructure required to provision FIAP’s Kubernetes platform on AWS.

## What it provisions

- VPC (public and private subnets), NAT Gateway, and routing
- Amazon EKS cluster with managed node groups
- IAM resources for controllers (ALB Controller, Cluster Autoscaler, External Secrets)
- ECR repositories for application images
- API Gateway (HTTP) for API proxy and authentication routes
- Secrets Manager for secrets (JWT)
- Kubernetes add-ons via Helm/Kubernetes (optional, enabled after cluster creation)

## Main outputs

- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
- `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data`
- `ecr_repository_url`, `jwt_secret_arn`, `api_gateway_url`

## Module architecture

- `modules/networking`: VPC, subnets, NAT, route tables, and subnet outputs
- `modules/eks`: (local or remote module) EKS, IAM roles, security groups, and node groups
- `modules/app`: ECR, API Gateway, IAM roles, and application secrets

## Backend / State Management

- The `main` branch currently uses an S3 backend (`main.tf` contains `backend "s3"`).
- Note: branches/environments may use different backends if the `terraform {}` block in the branch points to another backend (e.g., Terraform Cloud).

## CI / Workflow

- File: `.github/workflows/terraform.yml`
- Triggers: `push` and `pull_request` for the `main` and `develop` branches.
- Jobs:
  - `plan`: always runs on PRs/pushes; executes `terraform init`, `fmt -check`, `validate`, and `plan`.
  - `apply`: runs only on `push` events and depends on `plan`; executes `terraform init` and `terraform apply -auto-approve`.

### How it differentiates staging vs production

The workflow injects the `TF_VAR_environment` variable using the following expression:

```yaml
${{ github.ref_name == 'main' && 'prod' || 'hmg' }}
```

Result:

- If the ref is `main` → `TF_VAR_environment=prod`
- Otherwise → `TF_VAR_environment=hmg`

The `apply` job also sets the GitHub Environment based on the branch:

```yaml
environment: ${{ github.ref_name == 'main' && 'production' || 'staging' }}
```

## Variables and secrets (CI)

Variables defined in the workflow:

- `TF_VAR_project_name`
- `TF_VAR_jwt_secret`
- `TF_VAR_api_backend_url`
- `TF_VAR_auth_lambda_invoke_arn`
- `TF_VAR_enable_datadog`
- `TF_VAR_datadog_api_key`

Required repository/environment secrets:

- `AWS_ROLE_ARN`
- `JWT_SECRET`
- `DATADOG_API_KEY`

## How to use locally

1. Configure AWS credentials locally (e.g., using `aws configure` or `aws-vault`) with the required permissions.

2. Initialize Terraform:

```bash
terraform init
```

3. Review the plan for the staging environment (non-main branches):

```bash
TF_VAR_environment=hmg terraform plan
```

4. Review the production plan (`main` branch):

```bash
TF_VAR_environment=prod terraform plan
```

5. Apply locally (only do this if you understand which backend is being used):

```bash
TF_VAR_environment=prod terraform apply -auto-approve
```

Note: the backend in use depends on the `terraform {}` block defined in the current branch’s `main.tf` — verify it before applying.

## How to use via CI (GitHub Actions)

- Push to `develop` or opening a PR → automatically runs `plan`.
- Push to `main` → runs both `plan` and `apply` (for `push` events).
- Ensure the required secrets and variables (`AWS_ROLE_ARN`, `JWT_SECRET`, `DATADOG_API_KEY`, etc.) are configured in the repository or GitHub environments.

## Recommendations

- Standardize the backend across branches (for example, adopt Terraform Cloud for all environments) to avoid isolated state files.
- Convert `eks` into a local module (`modules/eks`) — it may currently be remote; keeping everything local improves reviewability and versioning consistency.
- Document which workspaces (if using Terraform Cloud) or S3 state keys are used for each environment.

## Where to look in the repository

- Root `main.tf`: `main.tf`
- Modules: `modules/networking`, `modules/eks` (if present), `modules/app`
- CI workflow: `.github/workflows/terraform.yml`

---

If you want, I can also open a PR that:

- updates `main` to use the same `cloud { ... }` backend you prefer, or
- updates the workflow to pass backend configuration dynamically per branch (S3 vs Cloud).
