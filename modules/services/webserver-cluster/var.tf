variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "remote_state_bucket" {
  description = "Name of bucket to store the remote state"
  type        = string
}

variable "remote_state_path" {
  description = "Path to the remote state"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 10
}

variable "ami" {
  type    = string
  default = "ami-03e3a1b55173c30c6"
}

variable "server_port" {
  description = "The ingress/egress port for TCP traffic"
  type        = number
  default     = 8080
}

// Variables specific to this module, can't be overriden by things that implement the module
// For DRY + Neatness
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = -1
  tcp_protocol = "tcp"
  all_ips      = "[0.0.0.0/0]"
}
