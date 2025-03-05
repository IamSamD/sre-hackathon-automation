variable "aws_region" {
  type    = string
  default = "eu-west-1" // Ireland
}

variable "default_tags" {
  description = "tags for all resources"
  type        = map(string)
  default = {
    "app"     = "automation_app"
    "project" = "sre_away_day"
  }
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "aws_ecr_url" {
  type    = string
  default = "iamsamd/automation-api"
}

variable "container_image_version" {
  type    = string
  default = "1.0.5"
}

variable "cloudwatch_log_group_name" {
  type    = string
  default = "automation"
}

variable "cloudwatch_log_prefix" {
  type    = string
  default = "ecs"
}
