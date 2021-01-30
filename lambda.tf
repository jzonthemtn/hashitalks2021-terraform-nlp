# Adapted from https://medium.com/analytics-vidhya/deploying-aws-lambda-function-with-terraform-custom-dependencies-7874407cd4fc

variable "path_source_code" {
  default = "lambda_function"
}

variable "function_name" {
  default = "aws_lambda_test"
}

variable "runtime" {
  default = "python3.7"
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

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid = "AllowInvokingLambdas"
    effect = "Allow"

    resources = [
      "arn:aws:lambda:*:*:function:*"
    ]

    actions = [
      "lambda:InvokeFunction"
    ]
  }

  statement {
    sid = "AllowCreatingLogGroups"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*"
    ]

    actions = [
      "logs:CreateLogGroup"
    ]
  }

  statement {
    sid = "AllowWritingLogs"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "lambda_iam_policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
  role = aws_iam_role.lambda_exec_role.name
}

# ===

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.ml_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.aws_lambda_test.arn}"
}

# ===

resource "null_resource" "install_python_dependencies" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/create_pkg.sh"

    environment = {
      source_code_path = var.path_source_code
      function_name = var.function_name
      path_module = path.module
      runtime = var.runtime
      path_cwd = path.cwd
    }
  }
}

data "archive_file" "create_dist_pkg" {
  depends_on = ["null_resource.install_python_dependencies"]
  source_dir = "./lambda_function/"
  output_path = var.output_path
  type = "zip"
}

resource "aws_lambda_function" "aws_lambda_test" {
  function_name = var.function_name
  description = "NLP NER Model Training"
  handler = "lambda_function.lambda.lambda_handler"
  runtime = var.runtime

  role = aws_iam_role.lambda_exec_role.arn
  memory_size = 128
  timeout = 300

  depends_on = [null_resource.install_python_dependencies]
  source_code_hash = data.archive_file.create_dist_pkg.output_base64sha256
  filename = data.archive_file.create_dist_pkg.output_path
}
