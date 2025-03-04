data "aws_caller_identity" "current" {}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "../selfheal_lambda/"
  output_path = "lambda_function.zip"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "AutomationSelfHealLambdaExecutionRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = var.default_tags
}

resource "aws_iam_policy" "automation_selfheal_lambda" {
  name        = "AutomationSelfHealLambdaExecutionPolicy"
  description = "Exection role for automation example lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecs:GetTaskProtection",
          "ecs:ListAttributes",
          "ecs:ListServiceDeployments",
          "ecs:DescribeTaskSets",
          "ecs:DescribeClusters",
          "ecs:DescribeCapacityProviders",
          "ecs:ListTagsForResource",
          "ecs:ListTasks",
          "ecs:DescribeServiceDeployments",
          "ecs:DescribeServiceRevisions",
          "ecs:StopTask",
          "ecs:DescribeServices",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTasks",
          "ecs:ListServices",
          "ecs:ListServicesByNamespace",
          "ecs:ListAccountSettings",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:ListClusters"
        ],
        Resource = [
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/*/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service-deployment/*/*/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:container-instance/*/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task-set/*/*/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service-revision/*/*/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task-definition/*:*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:capacity-provider/*",
          "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/*/*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      }
    ]
  })

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "automation_selfheal_lambda" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.automation_selfheal_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_invokation" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.automation_selfheal_lambda.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.automation.arn
}

resource "aws_lambda_function" "automation_selfheal_lambda" {
  function_name = "automation-selfheal-lambda"
  filename      = "lambda_function.zip"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  tags = var.default_tags
}
