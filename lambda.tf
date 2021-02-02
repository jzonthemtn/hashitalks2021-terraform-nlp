# Adapted from https://medium.com/analytics-vidhya/deploying-aws-lambda-function-with-terraform-custom-dependencies-7874407cd4fc

variable "path_source_code" {
  default = "lambda_function"
}

variable "function_name" {
  default = "aws_lambda_test"
}

variable "output_path" {
  description = "Path to function's deployment package into local filesystem. eg: /path/lambda_function.zip"
  default     = "lambda_function.zip"
}

variable "distribution_pkg_folder" {
  description = "Folder name to create distribution files..."
  default     = "lambda_dist_pkg"
}

# ===

variable "lambda_payload_filename" {
  default = "lambda-handler/target/java-events-1.0-SNAPSHOT.jar"
}

resource "aws_lambda_function" "aws_lambda_test" {
  runtime          = "java11"
  filename         = var.lambda_payload_filename
  source_code_hash = filebase64sha256(var.lambda_payload_filename)
  function_name    = "nlp-consumer-function"
  # lambda handler function name, it will be full class path name with package name
  handler     = "example.Handler"
  timeout     = 60
  memory_size = 256
  role        = aws_iam_role.iam_role_for_lambda.arn
  depends_on  = [aws_cloudwatch_log_group.log_group]

}

# lambda role
resource "aws_iam_role" "iam_role_for_lambda" {
  name               = "lambda-invoke-role"
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
         "Resource":"arn:aws:s3:::${aws_sqs_queue.ml_queue.arn}"
      },
      {
         "Effect":"Allow",
         "Action":["s3:ListBucket"],
         "Resource":"arn:aws:s3:::${aws_s3_bucket.ml_bucket.id}"
      },
      {
         "Effect":"Allow",
         "Action":["s3:PutObject"],
         "Resource":"arn:aws:s3:::${aws_s3_bucket.ml_bucket.id}/*"
      }
    ]
  }
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}
