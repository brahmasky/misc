variable "env" {
  description = "AWS workspace environment - dev/tst/stg/prod"
  type        = string
}
variable "tanium_private_key" {
  description = "SSH private key name for TanOS"
  type        = string
}
variable "tanos_owner" {
  description = "Owner account ID for TanOS image"
  type        = string
}
variable "tanos_version" {
  description = "Version number as displayed for TanOS image"
  type        = string
}
variable "tanium_fqdn_hostname" {
  description = "hostname of tanium fqdn, default is tanium"
}
variable "tanium_dns_zone" {
  description = "Hosted zone name for the specific environment"
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

#variable "instance_type" {
#  description = "EC2 instance type for TanOS instances"
#}

variable "tanos_details" {
  description = "instance related variables"
  type = map(object({
    az_zone       = string
    role          = string
    instance_name = string
    instance_type = string
    ip            = string
    ebs_type      = string
    ebs_size      = number
  }))
}

# variables for tanium ALB
variable "tanium_server_alb_name" {
  description = "Name for Tanium Server ALB"
  type        = string
}

variable "tanium_server_tg_name" {
  description = "Name for Tanium Server Target Group"
  type        = string
}


# variables for sns topic and subscription to be used in aws_monitoring module
variable "sns_topic_name" {
  description = "Name for SNS topic"
  type        = string
}
variable "sns_feedback_role_name" {
  description = "IAM role name for SNS feedback"
  type        = string
}
variable "sns_feedback_sample_rate" {
  description = "SNS feedback sample rate"
  type        = number
}

variable "sns_subscription_email" {
  description = "Tanium team email address for SNS subscription"
  type        = string
}

# variable "tanium_monitoring_nlb_name" {
#   description = "Name for Tanium Appliance Monitoring NLB"
#   type        = string
# }

# variable "tanium_monitoring_tg_prefix" {
#   description = "Prefix for the name of Tanium Appliance Monitoring Target Group"
#   type        = string
# }

# variable "tanium_appliance_monitoring_ports" {
#   description = "List of ports to be used by tanium appliance monitoring"
#   type        = list(any)
# }
# variable "tanium_appliance_monitoring_protocol" {
#   description = "Generic health check protocol to be used by tanium appliance monitoring"
#   type        = string
# }

variable "monitoring_dashboard_name" {
  description = "Monitoring dashboard name"
  type        = string
}

variable "lambda_iam_role" {
  description = "IAM role for SNMP polling function"
  type        = string
}

variable "snmp_function_name" {
  description = "Lambda function name for the snmp monitor"
  type        = string
}

variable "snmp_polling_schedule" {
  description = "snmp monitoring schedule in cron expressions"
  type        = string
}

variable "api_function_name" {
  description = "Lambda function name for the rbac API"
  type        = string
}

variable "api_call_schedule" {
  description = "Cron schedule to call Tanium rbac API"
  type        = string
}
