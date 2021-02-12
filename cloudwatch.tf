resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/java_lambda_function"
}

resource "aws_cloudwatch_log_group" "nlp-training" {
  name = "nlp-training"
}

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

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "consume-nlp-training-queue"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "run_lambda_every_one_minute" {
  rule      = aws_cloudwatch_event_rule.every_one_minute.name
  target_id = "lambda"
  arn       = aws_lambda_function.aws_lambda_test.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_test.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute.arn
}
