data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "archive_file" "generate_article" {
  type        = "zip"
  source_dir  = "${path.module}/functions/py/generate_article"
  output_path = "${path.module}/functions/zip/lambda_generate_article.zip"
}

data "archive_file" "get_article" {
  type        = "zip"
  source_dir  = "${path.module}/functions/py/get_article"
  output_path = "${path.module}/functions/zip/lambda_get_article.zip"
}