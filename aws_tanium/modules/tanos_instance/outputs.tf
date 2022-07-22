output "tanos_instance_id" {
  description = "IDs of tanos instances"
  value       = aws_instance.tanos_instance.*.id
}

# output "tanos_instance_ids" {
#   description = "IDs of tanos instances"
#   value = zipmap(keys(var.tanos_details)[*], values(aws_instance.tanos_instances)[*].id)
#   # value = 
#   # value = {
#   #   for ts in sort(keys(var.tanos_details)): ts => aws_instance.tanos_instances[ts].ids
#   # }
# }