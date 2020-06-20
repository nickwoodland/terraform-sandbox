// Request a reference for our default VPC, we will need to drill down into it for config data
data "aws_vpc" "default" {
  default = true
}

// Use the ID of our default VPC to request the available subnets within the VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}


// configure a remote tfstate file as a datasource so that we may read from it
// - specifically, the DB details 
data "terraform_remote_state" "db_state" {
  backend = "s3"

  config = {
    bucket = "7ohxt2pfveky"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "template_file" "provision" {
  template = file("${path.module}/templates/provision.sh")

  vars = {
    db_address = data.terraform_remote_state.db_state.outputs.address
    db_port    = data.terraform_remote_state.db_state.outputs.port
  }
}

// top level config for our ASG. 
resource "aws_autoscaling_group" "terraform_sandbox_asg" {
  launch_configuration = aws_launch_configuration.terraform_sandbox_lc.name

  // tell our autoscaling group to use the subnets we retrieved earlier when assigning IPs
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  // make our ASG aware of our target group
  target_group_arns = [aws_lb_target_group.terraform_sandbox_asg_target.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "terraform-sandbox-asg"
    propagate_at_launch = true
  }
}


// Load balancer resource for the autoscaling group
resource "aws_lb" "terraform_sandbox_lb" {
  name               = "${var.cluster_name}-asg"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.terraform_sandbox_alb_security_group.id]
}

// A target group is a subgroup of potential servers within an ASG. 
// The job of the target group is to monitor the servers in an ASG and inform the LB which of them are healthy
// so traffic can be routed to them
resource "aws_lb_target_group" "terraform_sandbox_asg_target" {
  name     = "${var.cluster_name}-asg-target"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = 200
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

// Listener resource for the load balancer
resource "aws_lb_listener" "terraform_sandbox_listener" {
  load_balancer_arn = aws_lb.terraform_sandbox_lb.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code  = 404
    }
  }
}

// Give our LB listener some rules
resource "aws_lb_listener_rule" "terraform_sandbox_listener_rule" {
  listener_arn = aws_lb_listener.terraform_sandbox_listener.arn
  priority     = 100

  condition {
    // match any path
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    // forward the request to our target group
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_sandbox_asg_target.arn
  }
}


// Describe an image to be used in our ASG
resource "aws_launch_configuration" "terraform_sandbox_lc" {
  image_id        = "${var.ami}"
  instance_type   = "${var.image_type}"
  security_groups = [aws_security_group.terraform_sandbox_webserver_security_group.id]

  user_data = data.template_file.provision.rendered

  lifecycle {
    // this tells terraform that we must create a replacement for this resource before destroying it,
    // and update any references. Without this, we'd remove this resource first, leaving the autoscaling group in a broken state.
    create_before_destroy = true
  }
}


// define our webserver secuirty group
resource "aws_security_group" "terraform_sandbox_webserver_security_group" {
  name = "${var.cluster_name}-webserver-security-group"
}

// add a rule to our webserver security group 
// 
// we want to allow incoming traffic on a nonstard port for TCP (usually 8080) for security reasons
// 
// I ~think~ the load balancer knows to use this port due to the config in the load balancer target group 
// The listener has a rule to forward traffic to the Load balancer target group, which also specifies use of the same nonstandard port
// See the resources terraform_sandbox_listener_rule & terraform_sandbox_asg_target
resource "aws_security_group_rule" "allow_http_nonstandard_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.terraform_sandbox_webserver_security_group.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.any_ips
}

// define a security group for our load balancer. We want to allow incoming TCP traffic on port 80, 
// and allow all outgoing traffic 
resource "aws_security_group" "terraform_sandbox_alb_security_group" {
  name = "${var.cluster_name}-alb-security-group"
}

// add a rule to our security group
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.terraform_sandbox_alb_security_group.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.any_ips
}

// add a rule to our security group
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.terraform_sandbox_alb_security_group.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.any_ips
}
