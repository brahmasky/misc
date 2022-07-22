# account id
data "aws_caller_identity" "current" {}

## ami
data "aws_ami" "tanos_ami" {
  owners      = [var.tanos_owner]
  most_recent = true

  filter {
    name   = "name"
    values = [var.tanos_version]
  }
}

## vpc
data "aws_vpc" "tanium_vpc" {
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-*"]
  }
}

## managment SGs
data "aws_security_group" "cloud_mgmt_sg" {
  filter {
    name   = "tag:Name"
    values = ["cloud-company-a-*-etp-${var.env}-tanium-MGMT"]
  }
}

data "aws_security_group" "cloud_linux_mgmt_sg" {
  filter {
    name   = "tag:Name"
    values = ["cloud-ec2-linux-mgmt-sg"]
  }
}

data "aws_security_group" "tanium_mgmt_sg" {
  filter {
    name   = "tag:Name"
    values = ["tanium-${var.env}-mgmt-ec2-sg"]
  }
}

## internal controlled SG
data "aws_security_group" "alb_sg" {
  filter {
    name   = "tag:Name"
    values = ["tanium-${var.env}-alb-sg"]
  }
}

data "aws_security_group" "cloud_ic_sg" {
  filter {
    name   = "tag:Name"
    values = ["cloud-company-a-*-etp-${var.env}-tanium-INT"]
  }
}

## secured zone SG
data "aws_security_group" "cloud_sec_sg" {
  filter {
    name   = "tag:Name"
    values = ["cloud-company-a-*-etp-${var.env}-tanium-SEC"]
  }
}

# 

data "aws_security_group" "tanium_sec_sg" {
  # AWS DEV environment does not have custom secured SG for tanium
  count = var.env != "dev" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["tanium-${var.env}-sec-ec2-sg"]
  }
}


## management subnet for az1 and az2
# data "aws_subnet_ids" "mgmt_subnets" {
#   vpc_id = data.aws_vpc.tanium_vpc.id
#   filter {
#     name = "tag:Name"
#     values = ["company-a-*-etp-${var.env}-tanium-SUBNET-MGMT-B1*"]
#   }
# }
## aws_subnet_ids returns ids not in az order, so retreiving 3 zone separatly here, and join them togehter in outputs

data "aws_subnet" "mgmt_subnet_az1" {
  vpc_id = data.aws_vpc.tanium_vpc.id
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-SUBNET-MGMT-A1*"]
  }
}
data "aws_subnet" "mgmt_subnet_az2" {
  vpc_id = data.aws_vpc.tanium_vpc.id
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-SUBNET-MGMT-B1*"]
  }
}

## secured zone subnet for az1 and az2
data "aws_subnet" "sec_subnet_az1" {
  vpc_id = data.aws_vpc.tanium_vpc.id
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-SUBNET-SEC-A1*"]
  }
}
data "aws_subnet" "sec_subnet_az2" {
  vpc_id = data.aws_vpc.tanium_vpc.id
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-SUBNET-SEC-B1*"]
  }
}


## internally controlled subnet
data "aws_subnet_ids" "ic_subnets" {
  vpc_id = data.aws_vpc.tanium_vpc.id
  filter {
    name   = "tag:Name"
    values = ["company-a-*-etp-${var.env}-tanium-SUBNET-IC*"]
  }
}

## route53 zone
data "aws_route53_zone" "tanium_hosted_zone" {
  name         = "${var.tanium_dns_zone}."
  private_zone = true
}

## certificate
data "aws_acm_certificate" "tanium_cert" {
  domain = "tanium.${var.tanium_dns_zone}"
}

## IAM role name for SNMP polling function
data "aws_iam_role" "lambda_role" {
  name = var.lambda_iam_role
}