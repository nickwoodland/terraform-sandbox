// we're telling terraform we want to access a resource of type secret_version
// and export it to the local variable db_password
// we are filtering by the secret_id to get the specific secret we ned
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.secret_id
}


resource "aws_db_instance" "terraform_sandbox_db" {
  identifier_prefix = "tfs-db-"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "terraform_sandbox_db"
  username          = var.username

  // we retrieved a secret to the local data var db_password and we are now accessing the property secret_string
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)[var.secret_id]
}

