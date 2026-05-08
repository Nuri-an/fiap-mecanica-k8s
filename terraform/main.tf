terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "fiap-mecanica-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "database" {
  source = "./modules/database"

  project_name       = var.project_name
  environment        = var.environment
  db_username        = var.db_username
  db_password        = var.db_password
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  app_security_group = module.app.security_group_id
}

module "app" {
  source = "./modules/app"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  docker_image       = var.docker_image
  database_url       = module.database.database_url
  jwt_secret         = var.jwt_secret
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
}
