variable "tanium_artifactory_repo" {
  description = "tanium repo name on artifactory "
  type        = string
  default     = "dea-tanium-generic-dev-local"
}

# variable "lambda_package_filename" {
#   description = "filename for the lambda api rbac function"
#   type        = string
#   default     = "tanium-api-rbac.zip"
# }

variable "api_function_name" {}

variable "api_call_schedule" {}

variable "lambda_role_arn" {
  description = "ARN for the IAM role used by Lambda SNMP function"
  type        = string
}

variable "lambda_subnets" {
  description = "VPC subnet IDs where the lambda function is attached to"
  type        = list(string)
}

variable "lambda_security_groups" {
  description = "security group IDs for the management subnet used by lambda function"
  type        = list(string)
}

variable "lambda_timeout" {
  description = "timeout value for the lambda function in the unit of seconds"
  type        = number
  default     = 300
}
