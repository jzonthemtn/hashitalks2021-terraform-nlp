resource "aws_lambda_function" "aws_lambda_test" {
  runtime          = "java11"
  filename         = var.lambda_payload_filename
  source_code_hash = filebase64sha256(var.lambda_payload_filename)
  function_name    = "${var.name_prefix}-consumer-function"
  handler          = "example.Handler"
  timeout          = 60
  memory_size      = 256
  role             = aws_iam_role.iam_role_for_lambda.arn
  environment {
    variables = {
      s3_bucket        = aws_s3_bucket.bucket.id
      aws_logs_group   = aws_cloudwatch_log_group.nlp-training.name
      queue_url        = aws_sqs_queue.queue.id
      ecs_cluster_name = "${var.name_prefix}-ecs"
      region           = var.region
      max_tasks        = "1"
      debug            = "false"
      table_name       = aws_dynamodb_table.models_dynamodb_table.id
      task_role_arn    = aws_iam_role.task_role.arn
    }
  }
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name               = "${var.name_prefix}-lambda-invoke-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

# lambda policy
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name = "${var.name_prefix}-lambda-invoke-policy"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaPolicy",
        "Effect": "Allow",
        "Action": [
          "cloudwatch:PutMetricData",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ecs:*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy",
          "logs:CreateLogGroup",
          "xray:PutTelemetryRecords",
          "xray:PutTraceSegments"
        ],
        "Resource": "*"
      },
      {
         "Effect":"Allow",
         "Action":["sqs:*"],
         "Resource":"${aws_sqs_queue.queue.arn}"
      },
      {
         "Sid": "PolicyStatementToAllowUserToPassOneSpecificRole",
         "Effect": "Allow",
         "Action": [ "iam:PassRole" ],
         "Resource": "${aws_iam_role.task_role.arn}"
      },
      {
          "Sid": "ListAndDescribe",
          "Effect": "Allow",
          "Action": [
              "dynamodb:List*",
              "dynamodb:DescribeReservedCapacity*",
              "dynamodb:DescribeLimits",
              "dynamodb:DescribeTimeToLive"
          ],
          "Resource": "*"
      },
      {
          "Sid": "SpecificTable",
          "Effect": "Allow",
          "Action": [
              "dynamodb:*"
          ],
          "Resource": "${aws_dynamodb_table.models_dynamodb_table.arn}"
      }      
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}
