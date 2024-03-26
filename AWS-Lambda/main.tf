provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
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

# IAM policy for logging from a lambda

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}



resource "aws_lambda_function" "terraform_lambda_func" {
 filename                       = "${path.module}/python/hello-python.zip"
 function_name                  = "chethan-Lambda-Function"
 role                           = aws_iam_role.iam_for_lambda.arn
 handler                        = "hello-python.lambda_handler"
 runtime                        = "python3.8"
 depends_on                     = [aws_iam_role_policy_attachment.lambda_logs]
}

output "teraform_aws_role_output" {
 value = aws_iam_role.iam_for_lambda.name
}

output "teraform_aws_role_arn_output" {
 value = aws_iam_role.iam_for_lambda.arn
}

output "teraform_logging_arn_output" {
 value = aws_iam_policy.lambda_logging.arn
}


