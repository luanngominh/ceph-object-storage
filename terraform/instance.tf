resource "aws_key_pair" "ceph-key-pair" {
  key_name   = "ceph-key-pair"
  public_key = file("bootstrap/public_key.pem")
}

resource "aws_instance" "web" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"

  tags = {
    Name = "HelloWorld"
  }
}
