terraform {
  backend "s3" {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.remote_state_path}"
    region = "eu-west-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
