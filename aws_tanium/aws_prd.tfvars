env                           = "prd"
tanos_owner                   = "526666945233"
tanos_version                 = "Tanium TanOS 1.7.0.0084"
tanium_fqdn_hostname          = "tanium"
tanium_dns_zone               = "tanium.internal"
tanium_private_key            = "tanos"
tanium_server_health_port     = 443
tanium_server_health_protocol = "HTTPS"
tanos_details = {
  ts1 = {
    az_zone       = "a"
    role          = "ts"
    instance_name = "001"
    instance_type = "m5a.8xlarge"
    ip            = "1.1.1.1"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
  ts2 = {
    az_zone       = "b"
    role          = "ts"
    instance_name = "002"
    instance_type = "m5a.8xlarge"
    ip            = "2.2.2.2"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
  tz1 = {
    az_zone       = "a"
    role          = "tz"
    instance_name = "003"
    instance_type = "c5a.8xlarge"
    ip            = "1.1.1.1"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
  tz2 = {
    az_zone       = "b"
    role          = "tz"
    instance_name = "004"
    instance_type = "c5a.8xlarge"
    ip            = "2.2.2.2"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
  tm1 = {
    az_zone       = "a"
    role          = "tm"
    instance_name = "005"
    instance_type = "m5a.8xlarge"
    ip            = "1.1.1.1"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
  tm2 = {
    az_zone       = "b"
    role          = "tm"
    instance_name = "006"
    instance_type = "m5a.8xlarge"
    ip            = "1.1.1.1"
    ebs_type      = "gp3"
    ebs_size      = 2000
  },
}
tanium_server_alb_name   = "ts-alb"
tanium_server_tg_name    = "ts-tg"
sns_topic_name           = "tanium-monitoring-sns"
sns_feedback_role_name   = "CLOUDSNSFeedback"
sns_subscription_email   = "cod@some.com.au"
sns_feedback_sample_rate = 100
# tanium_appliance_monitoring_ports    = ["17472", "17477"]
# tanium_appliance_monitoring_protocol = "TCP"
# tanium_monitoring_nlb_name           = "monitoring-nlb"
# tanium_monitoring_tg_prefix          = "monitoring-tg"
monitoring_dashboard_name = "tanium-infrastructure-monitoring-dashboard"
lambda_iam_role           = "SNMPLambdaRole"
snmp_function_name        = "tanium-snmp-mon"
# every 5 mins for production
snmp_polling_schedule         = "cron(*/5 * ? * * *)"
api_function_name         = "tanium-api-rbac"
# twice a day at 3:37 and 15:37 AEST everyday
api_call_schedule       = "cron(37 5,17 ? * * *)"