output "aws_account_id" {
  description = "AWS account ID for current workspace"
  value       = data.aws_caller_identity.current.account_id
}

output "ami_id" {
  description = "TanOS image ID"
  value       = data.aws_ami.tanos_ami.image_id
}

output "vpc_id" {
  value = data.aws_vpc.tanium_vpc.id
}

output "mgmt_sg_ids" {
  description = "list for security groups ID used in management zone"
  value       = [data.aws_security_group.cloud_mgmt_sg.id, data.aws_security_group.cloud_linux_mgmt_sg.id, data.aws_security_group.tanium_mgmt_sg.id]
}

output "company_account_id" {
  description = "the 7 digit CI number that is specific to each workspace"
  value       = regex("[0-9]{7}", data.aws_security_group.cloud_mgmt_sg.name)
}

output "alb_sg_ids" {
  description = "list for security groups ID used in Internal Controlled zone"
  value       = [data.aws_security_group.alb_sg.id, data.aws_security_group.cloud_ic_sg.id]
}

output "sec_sg_ids" {
  description = "list for security groups ID used in Secured zone"
  # AWS DEV does not have custom SG for tanium
  value = var.env == "dev" ? [data.aws_security_group.cloud_sec_sg.id, data.aws_security_group.cloud_linux_mgmt_sg.id] : [data.aws_security_group.cloud_sec_sg.id, data.aws_security_group.cloud_linux_mgmt_sg.id, data.aws_security_group.tanium_sec_sg[0].id]
}

output "mgmt_subnet_ids" {
  description = "management zone subnet id list for the first 2 az"
  value       = [data.aws_subnet.mgmt_subnet_az1.id, data.aws_subnet.mgmt_subnet_az2.id]
}

output "sec_subnet_ids" {
  description = "secured zone subnet id list for the first 2 az"
  value       = [data.aws_subnet.sec_subnet_az1.id, data.aws_subnet.sec_subnet_az2.id]
}

output "ic_subnet_ids" {
  value = data.aws_subnet_ids.ic_subnets.ids
}

output "tanium_hosted_zone_id" {
  value = data.aws_route53_zone.tanium_hosted_zone.zone_id
}

output "tanium_cert_arn" {
  value = data.aws_acm_certificate.tanium_cert.arn
}

output "lambda_role_arn" {
  value = data.aws_iam_role.lambda_role.arn
}