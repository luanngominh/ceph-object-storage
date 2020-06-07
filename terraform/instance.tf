resource "aws_key_pair" "ceph-key-pair" {
  key_name   = "ceph-key-pair"
  public_key = file("bootstrap/public_key.pem")
}

resource "aws_instance" "ceph" {
  count = "${var.number_of_instance}"
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"

  key_name = "${aws_key_pair.ceph-key-pair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow-all-traffic-local.id}"]
  subnet_id = "${aws_subnet.ceph-vpc-public.id}"
  private_ip = "1.13.1.2${count.index + 1}"
  associate_public_ip_address = true

  root_block_device {
    volume_size = "20"
    volume_type = "standard"
  }

  # Add some disk
  dynamic "ebs_block_device" {
    for_each = var.disk_settings

    content {
      device_name = ebs_block_device.value["device_name"]
      volume_size = ebs_block_device.value["volume_size"]
      volume_type = ebs_block_device.value["volume_type"]
    }
  }

  tags = {
    Name = "ceph-${count.index + 1}"
  }

  provisioner "file" {
    source      = "bootstrap/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = "${self.public_ip}"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh ${var.number_of_instance} ${var.ceph_domain} ${count.index + 1}.${var.ceph_domain}",
      "rm -f /tmp/script.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = "${self.public_ip}"
      private_key = "${file(var.ssh_key_private)}"
    }
  }
}
