## Create an IAM role document for the ecs task execution
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create the IAM role and associate the role document
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "automation-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json

  tags = var.default_tags
}

# Attach the IAM role to the Managed AmazonECSTaskExecutionRolePolicy
# allowing the ECS Role to assume the managed role.
# In simple language this gives the permissions in the managed policy to the role used by the ECS task
# allowing the ecs task to pull from our container registry and pipe logs to Cloudwatch
resource "aws_iam_role_policy_attachment" "attach_ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}
