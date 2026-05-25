terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "fiap_mecanica"

    workspaces {
      tags = ["fiap-mecanica-k8s"]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}


data "terraform_remote_state" "platform" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.platform_workspace_name
    }
  }
}
module "eks" {
  source = "./modules/eks"

  project_name         = var.project_name
  environment          = var.environment
  kubernetes_version   = var.kubernetes_version
  cluster_name         = "${var.project_name}-${var.environment}"
  vpc_id               = module.networking.vpc_id
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  desired_node_count   = var.desired_node_count
  min_node_count       = var.min_node_count
  max_node_count       = var.max_node_count
  node_instance_types  = var.node_instance_types
  aws_region           = var.aws_region
  internal_alb_arn     = module.networking.internal_alb_arn
  eks_target_group_arn = module.networking.eks_target_group_arn
}

module "apigateway" {
  source = "./modules/apigateway"

  project_name                             = var.project_name
  environment                              = var.environment
  vpc_id                                   = module.networking.vpc_id
  private_subnet_ids                       = module.networking.private_subnet_ids
  backend_listener_arn                     = module.networking.backend_listener_arn
  api_gateway_stage_name                   = var.api_gateway_stage_name
  aws_region                               = var.aws_region
  lambda_authorizer_function_arn           = data.terraform_remote_state.platform.outputs.lambda_authorizer_function_arn
  lambda_authorizer_identity_sources       = data.terraform_remote_state.platform.outputs.lambda_authorizer_identity_sources
  lambda_authorizer_payload_format_version = data.terraform_remote_state.platform.outputs.lambda_authorizer_payload_format_version
  lambda_authorizer_name                   = data.terraform_remote_state.platform.outputs.lambda_authorizer_name
  auth_lambda_function_arn                 = data.terraform_remote_state.platform.outputs.auth_lambda_function_arn
  auth_lambda_payload_format_version       = data.terraform_remote_state.platform.outputs.auth_lambda_payload_format_version
}
