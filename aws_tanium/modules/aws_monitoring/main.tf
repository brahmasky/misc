resource "aws_sns_topic" "tanium_monitoring" {
  name = var.sns_topic_name
  # kms_master_key_id                      = "alias/company-a-np-1004374-etp-dev-tanium-KMS-CMK-SNS"
  kms_master_key_id                        = "alias/${var.sns_cmk_alias}"
  application_success_feedback_role_arn    = var.sns_feedback_role_arn
  application_failure_feedback_role_arn    = var.sns_feedback_role_arn
  application_success_feedback_sample_rate = var.sns_feedback_sample_rate
  http_success_feedback_role_arn           = var.sns_feedback_role_arn
  http_failure_feedback_role_arn           = var.sns_feedback_role_arn
  http_success_feedback_sample_rate        = var.sns_feedback_sample_rate
  lambda_success_feedback_role_arn         = var.sns_feedback_role_arn
  lambda_failure_feedback_role_arn         = var.sns_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.sns_feedback_sample_rate
  sqs_success_feedback_role_arn            = var.sns_feedback_role_arn
  sqs_failure_feedback_role_arn            = var.sns_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sns_feedback_sample_rate
}

resource "aws_sns_topic_subscription" "tanium_monitoring_email_subscription" {
  topic_arn = aws_sns_topic.tanium_monitoring.arn
  protocol  = "email"
  endpoint  = var.sns_subscription_email
}

resource "aws_cloudwatch_metric_alarm" "tanium_alb_health" {
  alarm_name          = "tanium-alb-health-443-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "10"
  evaluation_periods  = "10"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.alb_tg_arn_suffix
  }

  alarm_description = "[CRITICAL] - Tanium Web GUI not accessible"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}

# resource "aws_cloudwatch_metric_alarm" "tanium_nlb_health" {
#   for_each = var.nlb_tg_arn_suffix

#   alarm_name          = "tanium-nlb-health-${each.key}-${var.env}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   datapoints_to_alarm = "10"
#   evaluation_periods  = "10"
#   namespace           = "AWS/NetworkELB"
#   metric_name         = "UnHealthyHostCount"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "1"
#   treat_missing_data  = "notBreaching"

#   dimensions = {
#     LoadBalancer = var.nlb_arn_suffix
#     TargetGroup  = each.value
#   }

#   alarm_description = "[CRITICAL] - Tanium health port ${each.key} not accessible"
#   alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
# }


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.monitoring_dashboard_name

  dashboard_body = jsonencode(
    {
      "widgets" : [{
        "type" : "metric",
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", "${var.alb_tg_arn_suffix}", "LoadBalancer", "${var.alb_arn_suffix}"],
            [".", "RequestCount", ".", ".", ".", "."],
            [".", "TargetResponseTime", ".", ".", ".", "."],
            [".", "RequestCountPerTarget", ".", ".", ".", "."],
            [".", "TargetConnectionErrorCount", ".", ".", ".", "."]
          ],
          "region" : "ap-southeast-2",
          "title" : "ALB Health"
        }
        },
        # {
        #   "type" : "metric",
        #   "properties" : {
        #     "view" : "timeSeries",
        #     "stacked" : false,
        #     "metrics" : [
        #       # ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", "targetgroup/ts-tg/043d386cf91a7714", "LoadBalancer", "app/ts-alb/9d5788404dcd87e7"],
        #       for key, value in var.nlb_tg_arn_suffix :
        #       ["AWS/NetworkELB", "UnHealthyHostCount", "TargetGroup", value, "LoadBalancer", "${var.nlb_arn_suffix}"]
        #     ],
        #     "region" : "ap-southeast-2",
        #     "title" : "NLB Health"
        #   }
        # },
        {
          "type" : "metric",
          "properties" : {
            "view" : "timeSeries",
            "stacked" : false,
            "metrics" : [
              # ["AWS/EC2", "CPUUtilization", "InstanceId", "i-0024ebc91dd369220"],
              for key, value in var.tanos_instance_id_map :
              ["AWS/EC2", "CPUUtilization", "InstanceId", value[0]]
            ],
            "region" : "ap-southeast-2",
            "title" : "CPU Utilisation"
          }
        },
        {
          "type" : "metric",
          "properties" : {
            "view" : "timeSeries",
            "stacked" : false,
            "metrics" : concat(
              # ["AWS/EC2", "NetworkPacketsOut", "InstanceId", "i-0024ebc91dd369220"],
              # [".", "NetworkPacketsIn", ".", "."],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "NetworkPacketsOut", "InstanceId", value[0]]
              ],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "NetworkPacketsIn", "InstanceId", value[0]]
              ]
            ),
            "region" : "ap-southeast-2",
            "period" : 300,
            "title" : "Network Traffic"
          }
        },
        {
          "type" : "metric",
          "properties" : {
            "view" : "timeSeries",
            "stacked" : false,
            "metrics" : concat(
              # ["AWS/EC2", "EBSWriteBytes", "InstanceId", "i-0024ebc91dd369220"],
              # [".", "EBSWriteOps", ".", "."],
              # [".", "EBSReadBytes", ".", "."],
              # [".", "EBSReadOps", ".", "i-0024ebc91dd369220"],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "EBSWriteBytes", "InstanceId", value[0]]
              ],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "EBSReadBytes", "InstanceId", value[0]]
              ],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "EBSWriteOps", "InstanceId", value[0]]
              ],
              [for key, value in var.tanos_instance_id_map :
                ["AWS/EC2", "EBSReadOps", "InstanceId", value[0]]
              ]
            ),
            "region" : "ap-southeast-2",
            "title" : "EBS I/O"
          }
        }
      ]
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "tanium_cpu_alarm" {
  for_each = var.tanos_instance_id_map

  alarm_name          = "tanium-cpu-alarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "6"
  evaluation_periods  = "6"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = each.value[0]
  }

  alarm_description = "[CRITICAL] - Tanium Instance CPU Utilisation"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}

resource "aws_cloudwatch_metric_alarm" "tanium_memory_alarm" {
  for_each = var.tanos_instance_id_map

  alarm_name          = "tanium-memory-alarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "6"
  evaluation_periods  = "6"
  namespace           = "SNMP/Memory"
  metric_name         = "MemoryUtilisation"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = each.value[0]
  }

  alarm_description = "[CRITICAL] - Tanium Instance Memory Utilisation"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}


locals {
  volumes = flatten([
    for instance_key, instance_id in var.tanos_instance_id_map : [
      for volume in var.tanium_volume : {
        "volume_key" = format("%s:%s", instance_key, volume)
        "volume_id"  = format("%s:%s", instance_id[0], volume)
      }
    ]
  ])
}
resource "aws_cloudwatch_metric_alarm" "tanium_volume_alarm" {
  for_each = { for volume in local.volumes : volume.volume_key => volume }

  alarm_name          = "tanium-volume-alarm-${each.value.volume_key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "6"
  evaluation_periods  = "6"
  namespace           = "SNMP/Volume"
  metric_name         = "VolumeUtilisation"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    VolumeId = each.value.volume_id
  }

  alarm_description = "[CRITICAL] - Tanium Instance Volume Utilisation"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}

resource "aws_cloudwatch_metric_alarm" "tanium_snmp_lambda_alarm" {

  alarm_name          = "tanium-snmp-lambda-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "6"
  evaluation_periods  = "6"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.snmp_function_name
  }

  alarm_description = "[CRITICAL] - Tanium SNMP Lambda Execution Error"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}

resource "aws_cloudwatch_metric_alarm" "tanium_api_lambda_alarm" {

  alarm_name          = "tanium-api-lambda-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "6"
  evaluation_periods  = "6"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.api_function_name
  }

  alarm_description = "[CRITICAL] - Tanium API Lambda Execution Error"
  alarm_actions     = [aws_sns_topic.tanium_monitoring.arn]
}
