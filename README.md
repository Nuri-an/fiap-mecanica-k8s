# fiap-mecanica-k8s

Terraform for Kubernetes infrastructure on AWS, with EKS, internal ALB, and HTTP API Gateway using VPC Link.

## What this repository creates

- VPC with 2 public subnets and 2 private subnets
- Internet Gateway, NAT Gateway, and route tables
- Internal Application Load Balancer
- Internal target group and listener for cluster services
- Amazon EKS
- Managed node group
- Basic EKS add-ons (`vpc-cni`, `coredns`, `kube-proxy`)
- ECR repository for the application image
- HTTP API Gateway
- VPC Link for private traffic to the internal ALB
- Optional integration with Lambda authorizer and `POST /auth` Lambda

## Architecture

```text
API Gateway (HTTP)
       │
       ├─ VPC Link
       │
Internal ALB (private)
       │
       ├─ Listener (port 80)
       │
EKS Cluster
  └─ AWS Load Balancer Controller
     └─ Watches Ingress resources
        └─ Manages ALB targets & rules
           └─ Routes to Pods/Services
```

- `modules/networking`
  - creates the VPC, subnets, NAT, and internal ALB
  - exposes `backend_listener_arn` and `eks_target_group_arn`

- `modules/eks`
  - creates the EKS cluster, node group, security groups, and ECR

- `modules/apigateway`
  - creates the HTTP API, VPC Link, and `$default` route
  - forwards traffic to the private listener
  - can protect the default route with a Lambda authorizer
  - can expose `POST /auth` integrated with a Lambda

## Providers

The root [main.tf](./main.tf:1) uses:

- `aws`
- `kubernetes`
- `helm`
- `tls`

The `kubernetes` and `helm` providers use the EKS endpoint and certificate created by the repository itself.

## Terraform Cloud

This repository uses the Terraform Cloud `cloud` backend in [main.tf](./main.tf:1), with workspaces tagged as `fiap-mecanica-k8s`.

It also consumes outputs from a remote workspace using `data "terraform_remote_state" "platform"` to retrieve:

- `lambda_authorizer_function_arn`
- `lambda_authorizer_identity_sources`
- `lambda_authorizer_payload_format_version`
- `lambda_authorizer_name`
- `auth_lambda_function_arn`
- `auth_lambda_payload_format_version`

This remote workspace is defined by:

- `tfc_organization`
- `platform_workspace_name`

## Main variables

Defined in [variables.tf](./variables.tf:1):

- `project_name`
- `environment`
- `aws_region`
- `kubernetes_version`
- `desired_node_count`
- `min_node_count`
- `max_node_count`
- `node_instance_types`
- `tfc_organization`
- `platform_workspace_name`
- `api_gateway_stage_name`

The Lambda authorizer and auth Lambda variables also exist in the repository, but currently the root module receives these values through the platform workspace `terraform_remote_state`.

## Outputs

Exposed in [outputs.tf](./outputs.tf:1):

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `internal_alb_arn`
- `backend_listener_arn`
- `eks_target_group_arn`
- `cluster_name`
- `cluster_endpoint`
- `cluster_certificate_authority_data`
- `ecr_repository_url`
- `app_security_group`
- `api_gateway_id`
- `api_gateway_endpoint`
- `api_gateway_stage_invoke_url`
- `api_gateway_execution_arn`
- `api_gateway_authorizer_id`
- `vpc_link_id`
- `vpc_link_security_group_id`

## CI/CD

Workflow: [terraform.yml](.github/workflows/terraform.yml:1)

- Pull Request to `develop`
  - runs `fmt`, `validate`, and `plan`
  - uses the `Homolog` environment

- Pull Request to `main`
  - runs `fmt`, `validate`, and `plan`
  - uses the `Production` environment

- Push to `develop`
  - runs `apply`
  - uses the `fiap-mecanica-k8s-hmg` workspace by default

- Push to `main`
  - runs `apply`
  - uses the `fiap-mecanica-k8s-prod` workspace by default

## GitHub Environments

Create the following environments:

- `Homolog`
- `Production`

## Workflow secrets and variables

Required secret in each environment:

- `TF_API_TOKEN`

Variables used by the workflow:

- `TF_WORKSPACE_HMG`
- `TF_WORKSPACE_PROD`
- `TF_PLATFORM_WORKSPACE_HMG`: manually configured in GitHub, Terraform Cloud workspace name for the shared homolog infrastructure/platform state
- `TF_PLATFORM_WORKSPACE_PROD`: manually configured in GitHub, Terraform Cloud workspace name for the shared production infrastructure/platform state
- `TF_CLOUD_ORGANIZATION`
- `PROJECT_NAME`
- `AWS_REGION`
- `KUBERNETES_VERSION`
- `DESIRED_NODE_COUNT`
- `MIN_NODE_COUNT`
- `MAX_NODE_COUNT`
- `NODE_INSTANCE_TYPES`
- `API_GATEWAY_STAGE_NAME`

Recommended defaults:

- `KUBERNETES_VERSION=1.31`
- `API_GATEWAY_STAGE_NAME=$default`

Note:

- AWS credentials can be managed directly in the Terraform Cloud workspace, which is the recommended setup for this repository.

## Integration with other repositories

- `fiap-mecanica-db` should consume:
  - `vpc_id`
  - `private_subnet_ids`
  - `app_security_group`

- `fiap-mecanica-api` should consume:
  - `cluster_name`
  - `cluster_endpoint`
  - `cluster_certificate_authority_data`
  - `ecr_repository_url`
  - `eks_target_group_arn`
  - `internal_alb_arn`
  - `backend_listener_arn`

- `fiap-mecanica-lambda` should consume:
  - `api_gateway_execution_arn`

## Notes

- The API Gateway does not connect directly to EKS. It uses a VPC Link to the internal ALB listener.
- The `eks_target_group_arn` target group must be used by the application deployment or by a controller/ingress to register the backend in the load balancer.
- AWS credentials can remain in the Terraform Cloud workspace itself, which is the cleanest setup for this repository.
