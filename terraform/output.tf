output "ceph_vpc_id" {
  value = aws_vpc.ceph-vpc.id
}

output "ceph_vpc_public_subnet" {
  value = aws_subnet.ceph-vpc-public.id
}

output "ceph_vpc_interget_gateway" {
  value = aws_internet_gateway.ceph-vpc-igw.id
}

output "ceph_vpc_security_group" {
  value = aws_security_group.allow-all-traffic-local.id
}

output "ceph_key_pair" {
  value = aws_key_pair.ceph-key-pair.key_name
}

output "ceph_public_ip" {
  value = aws_instance.ceph[*].public_ip
}
