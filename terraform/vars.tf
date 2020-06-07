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

variable "ceph_domain" {
  type = string
  description = "Ceph domain"
}

variable "instance_type" {
  type = string
  description = "Instance type"
}

variable "instance_ami" {
  type = string
  description = "Instance AMI"
}

variable "number_of_instance" {
  type = string
  description = "Number of disk per instance"
}

variable "disk_settings" {
  type = list(map(string))
  description = "Disk setting for instance"

  default = [
    {
      device_name = "/dev/xvdb"
      volume_size = "50"
      volume_type = "standard"
    },
    {
      device_name = "/dev/xvdc"
      volume_size = "50"
      volume_type = "standard"
    },
    {
      device_name = "/dev/xvdd"
      volume_size = "50"
      volume_type = "standard"
    },
    {
      device_name = "/dev/xvde"
      volume_size = "50"
      volume_type = "standard"
    },
    {
      device_name = "/dev/xvdf"
      volume_size = "50"
      volume_type = "standard"
    }
  ]
}

variable "ssh_key_private" {
  type = string
}
