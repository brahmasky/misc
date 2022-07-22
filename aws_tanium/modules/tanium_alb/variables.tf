variable "vpc_id" {
  description = "VPC ID for the AWS workspace"
  type        = string
}
variable "tanium_server_health_port" {
  description = "health check port to be used by TS target group"
  type        = number
}
variable "tanium_server_health_protocol" {
  description = "health check protocol to be used by TS target group"
  type        = string
}

variable "ic_subnet_ids" {
  description = "list of subnets IDs for Internally Controlled zone"
  # type = list(string)
}
variable "alb_sg_ids" {
  description = "list of security group IDs for Internally Controlled zone"
  # type = list(string)
}

variable "tanium_hosted_zone_id" {
  description = "ID for AWS hosted zone"
}

variable "tanium_fqdn_hostname" {
  description = "hostname of tanium fqdn, default is tanium"
}
variable "tanium_dns_zone" {
  description = "Hosted zone name for the specific environment"
  type        = string
}

variable "ts_cert_arn" {
  description = "ARN of the web cert for tanium server"
  type        = string
}

variable "tanos_instance_id_map" {
  description = "map of tanos instance id returned from `tanos_instance` module"
}

variable "tanium_server_alb_name" {
  description = "Name for Tanium Server ALB"
  type        = string
}

variable "tanium_server_tg_name" {
  description = "Name for Tanium Server Target Group"
  type        = string
}

# variable "monitoring_env" {}
# variable "monitoring_subnet_ids" {}
# variable "tanium_appliance_monitoring_protocol" {}
# variable "tanium_appliance_monitoring_ports" {}
# variable "tanium_monitoring_nlb_name" {}
# variable "tanium_monitoring_tg_prefix" {}