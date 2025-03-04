resource "aws_cloudwatch_log_group" "automation" {
  name = "automation"

  tags = var.default_tags
}

resource "aws_ecs_cluster" "automation" {
  name = "automation"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.default_tags
}

resource "aws_cloudwatch_log_metric_filter" "automation" {
  name           = "automation-api-errors"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.automation.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "automation-api"
    value         = "1"
    default_value = "0"
    unit          = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "automation" {
  alarm_name          = "automation-api-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "automation-api"
  metric_name         = aws_cloudwatch_log_metric_filter.automation.metric_transformation[0].name
  period              = 10
  statistic           = "Sum"
  threshold           = 1

  alarm_actions      = [aws_lambda_function.automation_selfheal_lambda.arn]
  alarm_description  = "Alert when errors are seen from the automation-api"
  treat_missing_data = "ignore"

  tags = var.default_tags
}
