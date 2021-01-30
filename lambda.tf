# Adapted from https://medium.com/analytics-vidhya/deploying-aws-lambda-function-with-terraform-custom-dependencies-7874407cd4fc

variable "path_source_code" {
  default = "lambda_function"
}

variable "function_name" {
  default = "aws_lambda_test"
}

variable "output_path" {
  description = "Path to function's deployment package into local filesystem. eg: /path/lambda_function.zip"
  default = "lambda_function.zip"
}

variable "distribution_pkg_folder" {
  description = "Folder name to create distribution files..."
  default = "lambda_dist_pkg"
}

variable "bucket_for_videos" {
  description = "Bucket name for put videos to process..."
  default = "aws-lambda-function-read-videos"
}

# ===

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.ml_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.aws_lambda_test.arn}"
}

# ===

variable "lambda_payload_filename" {
  default = "lambda-handler/target/java-events-1.0-SNAPSHOT.jar"
}

resource "aws_lambda_function" "aws_lambda_test" {
  runtime          = "java11"
  filename      = var.lambda_payload_filename
  source_code_hash = filebase64sha256(var.lambda_payload_filename)
  function_name = "java_lambda_function"
  # lambda handler function name, it will be full class path name with package name
  handler          = "package.Handler"
  timeout = 60
  memory_size = 256
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  depends_on   = ["aws_cloudwatch_log_group.log_group"]

}

# lambda role
resource "aws_iam_role" "iam_role_for_lambda" {
  name = "lambda-invoke-role"
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
  name = "lambda-invoke-policy"
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
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "xray:PutTelemetryRecords",
          "xray:PutTraceSegments"
        ],
        "Resource": "*"
      },
      {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
        "sqs:*"
    ],
    "Resource": "*"
}
    ]
  }
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  role       = "${aws_iam_role.iam_role_for_lambda.name}"
  policy_arn = "${aws_iam_policy.iam_policy_for_lambda.arn}"
}

# ===

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/java_lambda_function"
}

# allow lambda to log to cloudwatch
data "aws_iam_policy_document" "cloudwatch_log_group_access_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:::*",
    ]
  }
}
