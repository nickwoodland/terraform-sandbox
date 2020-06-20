output "alb_dns_name" {
  value       = aws_lb.terraform_sandbox_lb.dns_name
  description = "Domain of our new ASG"
}

// We need to output this so its available in consumers of the module
output "asg_name" {
  value = aws_autoscaling_group.terraform_sandbox_asg.name
}

// We need to output this so its available in consumers of the module
output "webserver_security_group_id" {
  value = aws_security_group.terraform_sandbox_alb_security_group.id
}
