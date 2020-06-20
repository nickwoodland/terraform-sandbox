// This is in here instead of the module because it's production specific
resource "aws_autoscaling_schedule" "scale_out_business_hours" {
  scheduled_action_name = "${var.cluster_name}-scale-out-business-hours"
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.max_size
  recurrence            = "0 9 * * * "

  autoscaling_group_name = module.webserver_cluster.asg_name
}


resource "aws_autoscaling_schedule" "scale_in_business_hours" {
  scheduled_action_name = "${var.cluster_name}-scale-in-business-hours"
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.min_size
  recurrence            = "0 17 * * * "

  autoscaling_group_name = module.webserver_cluster.asg_name
}
