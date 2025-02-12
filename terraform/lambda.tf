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
          "arn:aws:ecs:*:392568538879:service/*/*",
          "arn:aws:ecs:*:392568538879:cluster/*",
          "arn:aws:ecs:*:392568538879:service-deployment/*/*/*",
          "arn:aws:ecs:*:392568538879:container-instance/*/*",
          "arn:aws:ecs:*:392568538879:task-set/*/*/*",
          "arn:aws:ecs:*:392568538879:service-revision/*/*/*",
          "arn:aws:ecs:*:392568538879:task-definition/*:*",
          "arn:aws:ecs:*:392568538879:capacity-provider/*",
          "arn:aws:ecs:*:392568538879:task/*/*",
          "arn:aws:logs:*:392568538879:log-group:*:log-stream:*",
          "arn:aws:logs:*:392568538879:log-group:*"
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
  source_arn    = "arn:aws:cloudwatch:eu-west-2:392568538879:alarm:automation-api-errors"
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
