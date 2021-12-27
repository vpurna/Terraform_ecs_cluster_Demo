provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "ecr-repo" {
  source              = "../modules/ecr-repo"
  ecr_repository_name = "grafanadashboard"
  image_mutability    = "MUTABLE"
  scan_on_push        = "true"
  appname             = "grafana_app"

}
