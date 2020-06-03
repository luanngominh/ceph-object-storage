variable "region" {
  type = string
  description = "Ceph is going to running on this region"
  default = "ap-south-east-1"
}

variable "aws_access_key_id" {
  type = string
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  type = "string"
  description = "AWS secret key"
}
