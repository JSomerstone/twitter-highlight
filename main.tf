terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "climate-rage-vpc"
  }
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "climate-rage-query-twitter"
  acl           = "private"
  force_destroy = true
}

data "archive_file" "lambda_query_twitter" {
  type = "zip"

  source_dir  = "${path.module}/query-twitter"
  output_path = "${path.module}/query-twitter.zip"
}

resource "aws_s3_bucket_object" "lambda_query_twitter" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "query-twitter.zip"
  source = data.archive_file.lambda_query_twitter.output_path

  etag = filemd5(data.archive_file.lambda_query_twitter.output_path)
}

resource "aws_lambda_function" "query_twitter" {
  function_name = "QueryTwitter"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_query_twitter.key

  runtime = "nodejs12.x"
  handler = "query.handler"

  source_code_hash = data.archive_file.lambda_query_twitter.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      TWITTER_API_KEY = var.twitter_api_key,
      TWITTER_API_SECRET = var.twitter_api_secret,
      TWITTER_ACCESS_TOKEN = var.twitter_access_token,
      TWITTER_ACCESS_SECRET = var.twitter_access_token_secret,
      TWITTER_USER = var.twitter_user,
      CACHE_RESULTS_SECONDS = var.cache_results_seconds,
    }
  }
}

resource "aws_cloudwatch_log_group" "query_twitter" {
  name = "/aws/lambda/${aws_lambda_function.query_twitter.function_name}"

  retention_in_days = 7
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [ "*" ]
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "query_twitter" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.query_twitter.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "query_twitter" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /highligh"
  target    = "integrations/${aws_apigatewayv2_integration.query_twitter.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_twitter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
