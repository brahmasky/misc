variable "ami_id" {}
variable "tanos_instance_type" {}
variable "tanium_private_key" {}
variable "tanium_dns_zone" {}
variable "tanium_hosted_zone_id" {}
# variables from tanos_details map
variable "tanos_instance_key" {}
variable "tanos_az" {}
variable "tanos_ip" {}
variable "tanos_name" {}
variable "tanos_role" {}
variable "tanos_ebs_type" {}
variable "tanos_ebs_size" {}
variable "tanos_subnet_ids" {
  description = "list of Subnet IDs for both AZ1 and AZ2"
}
variable "tanos_sg_ids" {
  description = "list of Security Groups IDs for both AZ1 and AZ2"
}
