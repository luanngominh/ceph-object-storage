variable "region" {
  type = string
  description = "Ceph is going to running on this region"
  default = "ap-southeast-1"
}

variable "aws_access_key_id" {
  type = string
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  type = string
  description = "AWS secret key"
}

variable "number_of_disk" {
  type = string
  description = "Number of disk per instance"
}

variable "disk_size" {
  type = string
  description = "Disk capacity"
}

variable "instance_type" {
  type = string
  description = "Instance type"
}

variable "instance_ami" {
  type = string
  description = "Instance AMI"
}
