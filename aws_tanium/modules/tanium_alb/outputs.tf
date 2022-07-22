output "ts_alb_arn_suffix" {
  description = "ARN of ALB for Tanium Server"
  value       = aws_lb.ts_alb.arn_suffix
}
output "ts_tg_arn_suffix" {
  description = "ARN of target group for Tanium Server"
  value       = aws_lb_target_group.ts_tg.arn_suffix
}
# output "monitoring_nlb_arn_suffix" {
#   description = "ARN of monitoring NLB"
#   value       = aws_lb.monitoring_nlb.arn_suffix
# }

# output "monitoring_tg_arn_suffix" {
#   description = "ARN of monitoring target groups"
#   # value       = aws_lb_target_group.monitoring_tg[*]
#   value = zipmap(keys(aws_lb_target_group.monitoring_tg)[*], values(aws_lb_target_group.monitoring_tg)[*].arn_suffix)
# }
