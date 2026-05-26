# fiap-mecanica-k8s

Terraform for the real Kubernetes infrastructure on AWS.

## What this repo creates

- VPC with public and private subnets
- Amazon EKS cluster
- Managed node group
- Basic EKS add-ons (`vpc-cni`, `coredns`, `kube-proxy`)
- ECR repository for the application image

## Main outputs

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `cluster_name`
- `cluster_endpoint`
- `cluster_certificate_authority_data`
- `ecr_repository_url`
- `app_security_group`

## CI/CD

Workflow: `./.github/workflows/terraform.yml`

- Pull Request to `develop`: `fmt` + `validate` + `plan`
- Pull Request to `main`: `fmt` + `validate` + `plan`
- Push to `develop`: `apply` to the homologation workspace
- Push to `main`: `apply` to the production workspace

## GitHub Environments

Create the following environments:

- `Homolog`
- `Production`

## Secrets and Vars

Required secret in each environment:

- `TF_API_TOKEN`

Recommended vars in each environment:

- `TF_WORKSPACE_HMG`
- `TF_WORKSPACE_PROD`
- `TF_CLOUD_ORGANIZATION`
- `PROJECT_NAME`
- `AWS_REGION`
- `KUBERNETES_VERSION`
- `DESIRED_NODE_COUNT`
- `MIN_NODE_COUNT`
- `MAX_NODE_COUNT`
- `NODE_INSTANCE_TYPES`

Recommended default:

- `KUBERNETES_VERSION=1.31`

Note:

- AWS credentials can be managed directly in the Terraform Cloud workspace, which is the recommended setup for this repository.

## Integration with other repos

- `fiap-mecanica-db` should consume:
  - `vpc_id`
  - `private_subnet_ids`
  - `app_security_group`

- `fiap-mecanica-api` should consume:
  - `cluster_name`
  - `cluster_endpoint`
  - `cluster_certificate_authority_data`
  - `ecr_repository_url`

## Structure

- `main.tf`: orchestrates `networking` and `eks`
- `modules/networking`: VPC, NAT, route tables, and subnets
- `modules/eks`: EKS, node group, security groups, ECR, and add-ons
