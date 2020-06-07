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


resource "aws_subnet" "ceph-vpc-public" {
  vpc_id = "${aws_vpc.ceph-vpc.id}"
  cidr_block = "1.13.1.0/24"

  tags = {
    Name = "ceph-vpc-public"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_internet_gateway" "ceph-vpc-igw" {
  vpc_id = "${aws_vpc.ceph-vpc.id}"

  tags = {
    Name = "ceph-vpc-igw"
  }
}

resource "aws_route_table" "ceph-vpc-public-route" {
  vpc_id = "${aws_vpc.ceph-vpc.id}"

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ceph-vpc-igw.id}"
  }

  tags = {
    Name = "ceph-vpc-public-route"
  }
}

resource "aws_security_group" "allow-all-traffic-local" {
  name        = "allow-all-traffic-local"
  description = "Allow all traffic local"
  vpc_id      = "${aws_vpc.ceph-vpc.id}"

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.ceph-vpc.cidr_block]
  }

  ingress {
    description = "SSH from others"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-all-traffic-local"
  }
}

resource "aws_route_table_association" "route-public-subnet-associate" {
  subnet_id = "${aws_subnet.ceph-vpc-public.id}"
  route_table_id = "${aws_route_table.ceph-vpc-public-route.id}"
}
