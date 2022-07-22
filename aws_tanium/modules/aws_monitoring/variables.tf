variable "env" {}
variable "sns_topic_name" {}
variable "sns_feedback_role_arn" {}
variable "sns_feedback_sample_rate" {}
variable "sns_subscription_email" {}
variable "sns_cmk_alias" {
  description = "Alias name for SNS encryption key"
}
variable "alb_arn_suffix" {}
variable "alb_tg_arn_suffix" {}
# variable "nlb_arn_suffix" {}
# variable "nlb_tg_arn_suffix" {
#   description = "a list of nlb target group suffix"
# }
variable "tanos_instance_id_map" {
  description = "map of tanos instance id returned from `tanos_instance` module"
}

variable "monitoring_dashboard_name" {}

variable "tanium_volume" {
  description = "list of volume to be monitored per tanium instance"
  type        = list(string)
  default     = ["/", "/var", "/var/log/audit", "/opt", "/tmp", "/home", "/cores", "/var/log"]
}

variable "snmp_function_name" {}
variable "api_function_name" {}