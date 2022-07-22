# using '-' in lambda function name, but '_' in python script as well as the package name
locals {
  lambda_function_name = replace(var.api_function_name, "-", "_")
  lambda_package_filename = "${var.api_function_name}.zip"
}

# download snmp lambda function package from artifactory
data "artifactory_file" "lambda_package" {
  repository  = var.tanium_artifactory_repo
  path        = "/terraform/${local.lambda_package_filename}"
  output_path = "./${local.lambda_package_filename}"
}

resource "aws_lambda_function" "tanium_api_rbac" {
  function_name = var.api_function_name
  role          = var.lambda_role_arn
  runtime       = "python3.9"

  filename         = local.lambda_package_filename
  source_code_hash = filebase64sha256(local.lambda_package_filename)
  package_type     = "Zip"

  
  handler = "${local.lambda_function_name}.lambda_handler"

  vpc_config {
    security_group_ids = var.lambda_security_groups
    subnet_ids         = var.lambda_subnets
  }

  timeout = var.lambda_timeout
}

resource "aws_cloudwatch_event_rule" "api_call_schedule" {
  name                = "api_call_schedule"
  schedule_expression = var.api_call_schedule
}


resource "aws_cloudwatch_event_target" "api_target" {
  rule      = aws_cloudwatch_event_rule.api_call_schedule.name
  target_id = "api_target"
  arn       = aws_lambda_function.tanium_api_rbac.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_tanium_api" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tanium_api_rbac.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.api_call_schedule.arn
}