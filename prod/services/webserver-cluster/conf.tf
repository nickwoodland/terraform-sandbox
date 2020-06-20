provider "aws" {
  region = "eu-west-1"
}

module "webserver_cluster" {
  source = "../../modules/services/webserver_cluster"

  cluster_name        = "terraform-sandbox-prod"
  remote_state_bucket = "7ohxt2pfveky"
  remote_state_path   = "prod/data-stores/mysql/terraform.tfstate"
}

