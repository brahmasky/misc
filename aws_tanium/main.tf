module "environment" {
  env             = var.env
  tanos_owner     = var.tanos_owner
  tanos_version   = var.tanos_version
  tanium_dns_zone = var.tanium_dns_zone
  lambda_iam_role = var.lambda_iam_role

  source = "./modules/environment"
}


module "tanos_instances" {
  # common variables across 3 types of tanos instances
  ami_id                = module.environment.ami_id
  tanium_private_key    = var.tanium_private_key
  tanium_hosted_zone_id = module.environment.tanium_hosted_zone_id
  tanium_dns_zone       = var.tanium_dns_zone

  # instance details from the objects map specific to tanium role
  for_each = var.tanos_details

  tanos_instance_key  = each.key
  tanos_ip            = each.value.ip
  tanos_name          = each.value.instance_name
  tanos_instance_type = each.value.instance_type
  tanos_ebs_type      = each.value.ebs_type
  tanos_ebs_size      = each.value.ebs_size
  tanos_az            = each.value.az_zone
  tanos_role          = each.value.role
  # pass in subnet and sg IDs for Module server in Secured zone, or Tanium/Zone Server in management zone
  tanos_subnet_ids = each.value.role == "tm" ? module.environment.sec_subnet_ids : module.environment.mgmt_subnet_ids
  tanos_sg_ids     = each.value.role == "tm" ? module.environment.sec_sg_ids : module.environment.mgmt_sg_ids

  source = "./modules/tanos_instance"
}

module "tanium_alb" {
  tanium_server_alb_name        = var.tanium_server_alb_name
  tanium_server_tg_name         = var.tanium_server_tg_name
  tanium_server_health_port     = var.tanium_server_health_port
  tanium_server_health_protocol = var.tanium_server_health_protocol
  vpc_id                        = module.environment.vpc_id
  alb_sg_ids                    = module.environment.alb_sg_ids
  ic_subnet_ids                 = module.environment.ic_subnet_ids
  ts_cert_arn                   = module.environment.tanium_cert_arn
  tanium_hosted_zone_id         = module.environment.tanium_hosted_zone_id
  tanium_fqdn_hostname          = var.tanium_fqdn_hostname
  tanium_dns_zone               = var.tanium_dns_zone
  tanos_instance_id_map         = zipmap(keys(var.tanos_details)[*], values(module.tanos_instances)[*].tanos_instance_id)

  # monitoring nlb and tg variables
  # monitoring_env                       = var.env
  # monitoring_subnet_ids                = module.environment.mgmt_subnet_ids
  # tanium_appliance_monitoring_ports    = var.tanium_appliance_monitoring_ports
  # tanium_appliance_monitoring_protocol = var.tanium_appliance_monitoring_protocol
  # tanium_monitoring_nlb_name           = var.tanium_monitoring_nlb_name
  # tanium_monitoring_tg_prefix          = var.tanium_monitoring_tg_prefix

  source = "./modules/tanium_alb"

}

data "aws_iam_role" "EBSBackupRole" {
  name = "EBSBackupRole"
}
resource "aws_dlm_lifecycle_policy" "tanium_lifecyclerole" {
  description        = "DLM lifecycle policy"
  execution_role_arn = data.aws_iam_role.EBSBackupRole.arn
  state              = "ENABLED"
  policy_details {
    resource_types = ["VOLUME"]
    schedule {
      name = "2 weeks of daily snapshots"
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }
      retain_rule {
        count = 14
      }
      tags_to_add = {
        SnapshotCreator = "DLM"
      }
      copy_tags = true
    }
    target_tags = {
      backup = "true"
    }
  }
}

module "tanium_snmp" {
  lambda_role_arn        = module.environment.lambda_role_arn
  lambda_subnets         = module.environment.mgmt_subnet_ids
  lambda_security_groups = module.environment.mgmt_sg_ids
  snmp_function_name     = var.snmp_function_name
  snmp_polling_schedule      = var.snmp_polling_schedule

  source = "./modules/lambda_snmp"
}

module "tanium_api_rbac" {
  lambda_role_arn        = module.environment.lambda_role_arn
  lambda_subnets         = module.environment.mgmt_subnet_ids
  lambda_security_groups = module.environment.mgmt_sg_ids
  api_function_name      = var.api_function_name
  api_call_schedule      = var.api_call_schedule

  source = "./modules/lambda_api_rbac"
}

locals {
  company_env = var.env == "prd" ? "pr" : "np"
}
module "tanium_monitoring" {

  env                      = var.env
  sns_topic_name           = var.sns_topic_name
  sns_feedback_role_arn    = "arn:aws:iam::${module.environment.aws_account_id}:role/${var.sns_feedback_role_name}"
  sns_feedback_sample_rate = var.sns_feedback_sample_rate
  sns_subscription_email   = var.sns_subscription_email
  snmp_function_name       = var.snmp_function_name
  api_function_name        = var.api_function_name

  sns_cmk_alias = "company-a-${local.company_env}-${module.environment.company_account_id}-etp-${var.env}-tanium-KMS-CMK-SNS"

  tanos_instance_id_map = zipmap(keys(var.tanos_details)[*], values(module.tanos_instances)[*].tanos_instance_id)
  alb_arn_suffix        = module.tanium_alb.ts_alb_arn_suffix
  alb_tg_arn_suffix     = module.tanium_alb.ts_tg_arn_suffix

  # nlb_arn_suffix    = module.tanium_alb.monitoring_nlb_arn_suffix
  # nlb_tg_arn_suffix = module.tanium_alb.monitoring_tg_arn_suffix

  monitoring_dashboard_name = var.monitoring_dashboard_name

  source = "./modules/aws_monitoring"

}

terraform {
  backend "artifactory" {}
}

