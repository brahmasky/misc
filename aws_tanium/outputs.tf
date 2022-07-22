# output "tanos_instance_ids" {
#   description = "IDs of tanos instances"
#   value       = zipmap(keys(var.tanos_details)[*], values(module.tanos_instances)[*].tanos_instance_id)
# }

# output "monitoring_tg_arn" {
#   value = module.tanium_alb.monitoring_tg_arn
# }