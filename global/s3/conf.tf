provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "7ohxt2pfveky"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
