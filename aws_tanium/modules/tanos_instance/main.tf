# provision network interfaces
resource "aws_network_interface" "nic" {
  # retrieve the first subnet id if its AZ1, otherwise taking the 2nd subnet id for AZ2
  subnet_id       = var.tanos_az == "a" ? var.tanos_subnet_ids[0] : var.tanos_subnet_ids[1]
  private_ips     = [var.tanos_ip]
  security_groups = var.tanos_sg_ids
  tags = {
    Name = var.tanos_name
  }
  lifecycle {
    ignore_changes = [
      attachment,
      tags,
    ]
  }
}

# provision Tanos appliances
resource "aws_instance" "tanos_instance" {
  ami           = var.ami_id
  instance_type = var.tanos_instance_type
  key_name      = "${var.tanium_private_key}-${var.tanos_instance_key}"
  tags = {
    Bootstrap = "false"
    Name      = var.tanos_name
    Role      = var.tanos_role
    backup    = "true"
  }
  # only ap-southeast-2 region is used
  availability_zone = format("ap-southeast-2%s", var.tanos_az)
  monitoring        = "true"
  # disable_api_termination = "true"
  network_interface {
    network_interface_id = aws_network_interface.nic.id
    device_index         = 0
  }
  root_block_device {
    tags = {
      Name   = var.tanos_name
      backup = "true"
    }
    encrypted   = true
    volume_type = var.tanos_ebs_type
    volume_size = 50
  }
  ebs_block_device {
    tags = {
      Name   = var.tanos_name
      backup = "true"
    }
    device_name = "/dev/xvdb"
    encrypted   = true
    volume_type = var.tanos_ebs_type
    volume_size = var.tanos_ebs_size
  }
  lifecycle {
    ignore_changes = [
      root_block_device,
      ebs_block_device,
      tags,
      key_name,
    ]
  }
}

# DNS record with hostname
resource "aws_route53_record" "tanos_host_dns" {
  zone_id = var.tanium_hosted_zone_id
  name    = "${var.tanos_name}.${var.tanium_dns_zone}"
  type    = "A"
  ttl     = "300"
  records = [var.tanos_ip]
}

# DNS record with instance name
resource "aws_route53_record" "tanos_host_fqdn" {
  zone_id = var.tanium_hosted_zone_id
  name    = "${var.tanos_instance_key}.${var.tanium_dns_zone}"
  type    = "A"
  ttl     = "300"
  records = [var.tanos_ip]
}
