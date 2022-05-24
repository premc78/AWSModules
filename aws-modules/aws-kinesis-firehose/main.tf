data "aws_s3_bucket_object" "splunk_hec_token_file" {
  bucket = var.bootstrap_bucket
  key    = "hec_token.txt"
}

locals {
  trimmed = chomp(data.aws_s3_bucket_object.splunk_hec_token_file.body)
  token   = split(" ", local.trimmed)
}

resource "aws_kinesis_firehose_delivery_stream" "splunk_kinesis_delivery_stream" {
  name        = "splunk-kinesis-firehose-${count.index}"
  destination = "splunk"
  count       = length(local.token)

  s3_configuration {
    role_arn        = aws_iam_role.splunk_kinesis_delivery_role.arn
    bucket_arn      = var.splunk_smartstore_bucket_arn
    buffer_size     = 5
    buffer_interval = 300
  }

  splunk_configuration {
    hec_endpoint               = "https://${var.splunk_elb_dns_alias_fqdn}:8088"
    hec_token                  = local.token[count.index]
    hec_acknowledgment_timeout = 180
    hec_endpoint_type          = "Raw"
    s3_backup_mode             = "AllEvents"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/Splunk-Firehose"
      log_stream_name = "SplunkDelivery"
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "splunk_kinesis_delivery_role" {
  name = format("%s-%s-splunk_kinesis_delivery_role", var.customer, var.project)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.account_id}"
        }
      }
    }
  ]
}
  EOF
  tags               = var.tags
}

resource "aws_iam_role_policy" "splunk_kinesis_delivery_role_policy" {
  name = format("%s-%s-splunk_kinesis_delivery_role_policy", var.customer, var.project)
  role = aws_iam_role.splunk_kinesis_delivery_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glue:GetTable",
                "glue:GetTableVersion",
                "glue:GetTableVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${var.splunk_smartstore_bucket_arn}",
                "${var.splunk_smartstore_bucket_arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/kinesisfirehose/Splunk-Firehose:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": "arn:aws:kinesis:${var.region}:${var.account_id}:stream/${aws_kinesis_firehose_delivery_stream.splunk_kinesis_delivery_stream[0].name}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "${var.kms_key_arn}"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "kinesis.${var.region}.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:${var.region}:${var.account_id}:stream/${aws_kinesis_firehose_delivery_stream.splunk_kinesis_delivery_stream[0].name}"
                }
            }
        }
    ]
}
EOF
}