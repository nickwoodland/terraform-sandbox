provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "7ohxt2pfveky"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
