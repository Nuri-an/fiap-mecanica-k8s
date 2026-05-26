terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }

  backend "s3" {
    bucket = "fiap-mecanica-terraform-state"
    key    = "k8s/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  cluster_name = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  enable_irsa                    = true
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      subnet_ids     = module.networking.private_subnet_ids
    }
  }

  tags = local.tags
}

# Commented out for initial infrastructure provisioning
# Uncomment after cluster is created for deploying apps
# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name
# }
#
# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_name
# }
#
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.this.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }
