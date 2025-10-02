# terraform/sqs.tf
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_prefix}-image-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "image_queue" {
  name                       = "${var.project_prefix}-image-queue"
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

# Grant S3 permission to send messages to SQS
resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.image_queue.id
  policy    = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid = "AllowS3SendMessage"
      Effect = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action = "sqs:SendMessage"
      Resource = aws_sqs_queue.image_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_s3_bucket.uploads.arn
        }
      }
    }]
  })
}

# S3 Notification to SQS
resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = aws_s3_bucket.uploads.id

  queue {
    queue_arn     = aws_sqs_queue.image_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg" # 예시: jpg만
  }

  depends_on = [aws_sqs_queue_policy.allow_s3]
}
