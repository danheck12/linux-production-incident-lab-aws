variable "project" {
  type    = string
  default = "linux-incident-lab"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_cidr" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "root_volume_gb" {
  type    = number
  default = 20
}

variable "extra_volume_gb" {
  type    = number
  default = 20
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "linux-incident-lab"
    Environment = "lab"
    Owner       = "danheck12"
  }
}
