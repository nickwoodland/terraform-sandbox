variable "username" {
  description = "DB master username"
  type        = string
  default     = "yijjbwznnes"
}

variable "secret_id" {
  description = "Reference to look up the DB secret"
  type        = string
  default     = "mysql-master-password-stage"
}
