provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}

resource "aws_vpc" "ceph-vpc" {
  cidr_block       = "1.13.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ceph-vpc"
  }
}


