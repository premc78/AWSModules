data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Remove leading slashes
  ssm_prefix = join("/", compact(split("/", var.ssm_prefix)))
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [aws_cloudwatch_log_group.default.arn]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.default.arn,
      "${aws_cloudwatch_log_group.default.arn}:*:*",
    ]
  }

  statement {
    actions = [
      "ssm:GetParameters",
    ]

    resources = [format(
      "arn:aws:ssm:%s:%s:parameter/%s/*",
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      local.ssm_prefix,
    )]
  }
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }

  # This statement is not required for production, but it's useful for debugging.
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [format(
        "arn:aws:iam::%s:root",
        data.aws_caller_identity.current.account_id,
      )]
    }
  }
}

resource "aws_iam_policy" "default" {
  name        = var.function_name
  path        = "/"
  description = "Policy controlling access granted to lambda function ${var.function_name}"
  policy      = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role" "default" {
  name               = var.function_name
  path               = "/"
  description        = "Role assumed by lambda function ${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_cloudwatch_log_group" "default" {
  name = "/aws/lambda/${var.function_name}"
}

resource "aws_lambda_function" "default" {
  description = "Stream events from AWS CloudWatch to Splunk event collector"

  # The function_name, runtime, memory_size, and timeout use variables
  # to facilitate testing of both new runtimes and new function versions.
  # End users will ordinarily use the default values.
  function_name = var.function_name

  runtime     = var.runtime
  memory_size = var.memory_size
  timeout     = var.timeout
  handler     = "index.handler"
  publish     = true
  role        = aws_iam_role.default.arn
  s3_bucket   = "drone-${local.region}-${local.account_id}"
  s3_key      = "splunk-aws-serverless-apps/splunk-cloudwatch-logs-processor.zip"

  environment {
    variables = {
      SPLUNK_CACHE_TTL = var.splunk_cache_ttl
      SSM_PREFIX       = var.ssm_prefix
    }
  }
}

