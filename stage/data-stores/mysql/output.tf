output "address" {
  value       = aws_db_instance.terraform_sandbox_db.address
  description = "DB Endpoint"
}

output "port" {
  value       = aws_db_instance.terraform_sandbox_db.port
  description = "DB Port"
}
