output "s3_bucket" {
value = aws_s3_bucket.uploads.bucket
}
output "lambda_role_arn" {
value = aws_iam_role.lambda_exec.arn
}