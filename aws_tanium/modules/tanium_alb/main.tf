# tanium target group and load balancer in Secured zone
resource "aws_lb_target_group" "ts_tg" {
  name                          = var.tanium_server_tg_name
  port                          = var.tanium_server_health_port
  protocol                      = var.tanium_server_health_protocol
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "least_outstanding_requests"

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 3600
  }
}

resource "aws_lb" "ts_alb" {
  name                       = var.tanium_server_alb_name
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = var.alb_sg_ids
  subnets                    = var.ic_subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_listener" "ts_alb_listener" {
  load_balancer_arn = aws_lb.ts_alb.arn
  port              = var.tanium_server_health_port
  protocol          = var.tanium_server_health_protocol
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ts_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ts_tg.arn
  }
}

resource "aws_route53_record" "tanium-fqdn" {
  zone_id = var.tanium_hosted_zone_id
  name    = "${var.tanium_fqdn_hostname}.${var.tanium_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ts_alb.dns_name]
}

resource "aws_lb_target_group_attachment" "ts_tg_attachment" {
  # create target group attachment for tanium server only (key = 'tanium_server*')
  for_each = {
    for key, value in var.tanos_instance_id_map : key => value
    if length(regexall("ts", key)) > 0
  }

  target_group_arn = aws_lb_target_group.ts_tg.arn
  target_id        = each.value[0]
  port             = var.tanium_server_health_port
}
# resource "aws_lb_target_group" "monitoring_tg" {
#   for_each = toset(var.tanium_appliance_monitoring_ports)

#   name     = "${var.tanium_monitoring_tg_prefix}-${each.value}"
#   port     = each.value
#   protocol = var.tanium_appliance_monitoring_protocol
#   vpc_id   = var.vpc_id
# }

# # create target group attachment for tanium server and zone server on port 17472
# resource "aws_lb_target_group_attachment" "monitoring_tg_attachment_17472" {
#   for_each = {
#     for key, value in var.tanos_instance_id_map : key => value
#     if length(regexall("ts|tz", key)) > 0
#   }

#   target_group_arn = aws_lb_target_group.monitoring_tg["17472"].arn
#   target_id        = each.value[0]
#   port             = 17472
# }


# # create target group attachment for module server, or tanium server in dev, on port 17477
# resource "aws_lb_target_group_attachment" "monitoring_tg_attachment_17477" {
#   for_each = {
#     for key, value in var.tanos_instance_id_map : key => value
#     if length(regexall("tm", key)) > 0 || (length(regexall("ts", key)) > 0 && var.monitoring_env == "dev")
#   }

#   target_group_arn = aws_lb_target_group.monitoring_tg["17477"].arn
#   target_id        = each.value[0]
#   port             = 17477
# }

# resource "aws_lb" "monitoring_nlb" {

#   name                       = var.tanium_monitoring_nlb_name
#   internal                   = true
#   load_balancer_type         = "network"
#   subnets                    = var.monitoring_subnet_ids
#   enable_deletion_protection = false
# }

# resource "aws_lb_listener" "monitoring_nlb_listener" {
#   for_each = aws_lb_target_group.monitoring_tg

#   load_balancer_arn = aws_lb.monitoring_nlb.arn
#   port              = each.key
#   protocol          = var.tanium_appliance_monitoring_protocol

#   default_action {
#     type             = "forward"
#     target_group_arn = each.value.arn
#   }

# }

# creating separate (targeted) target group for TS servers and alb rules to monitor the access issues with 2nd instance
resource "aws_lb_target_group" "ts_tg_targeted" {
  for_each = {
    for key, value in var.tanos_instance_id_map : key => value
    if length(regexall("ts", key)) > 0
  }
  name                          = "${each.key}-tg"
  port                          = var.tanium_server_health_port
  protocol                      = var.tanium_server_health_protocol
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "least_outstanding_requests"

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 3600
  }
}

resource "aws_lb_target_group_attachment" "ts_tg_attachment_targeted" {
  # create target group attachment for tanium server only (key = 'tanium_server*')
  for_each = {
    for key, value in var.tanos_instance_id_map : key => value
    if length(regexall("ts", key)) > 0
  }

  target_group_arn = aws_lb_target_group.ts_tg_targeted[each.key].arn
  target_id        = each.value[0]
  port             = var.tanium_server_health_port
}

# LB rules to target at specific instance 
resource "aws_alb_listener_rule" "ts_alb_targeted_rule" {
  for_each = {
    for key, value in var.tanos_instance_id_map : key => value
    if length(regexall("ts", key)) > 0
  }

  listener_arn = aws_lb_listener.ts_alb_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ts_tg_targeted[each.key].arn
  }
  condition {
    host_header {
      values = ["${each.key}web.*"]
    }
  }
}

resource "aws_route53_record" "ts_fqdn_targeted" {
  for_each = {
    for key, value in var.tanos_instance_id_map : key => value
    if length(regexall("ts", key)) > 0
  }

  zone_id = var.tanium_hosted_zone_id
  name    = "${each.key}web.${var.tanium_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ts_alb.dns_name]
}
