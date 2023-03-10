variable "ami" {
  description = "EC2 default AMI"
  type        = string
  default     = "ami-0557a15b87f6559cf"
}

variable "username" {
  type = string
}

variable "Repository" {
  type = string
}

variable "db_password" {
  type = string
}

variable "connection" {
  type    = string
  default = "localhost"
}