variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "t3.micro"
}

variable "docker_image" {
  description = "Dcoker image"
  type        = string
}

variable "ami_id" {
  description = "AMI a utilizar (Amazon Linux)"
  type        = string
  default     = "ami-0c02fb55956c7d316"   # us-east-1
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 4
}
