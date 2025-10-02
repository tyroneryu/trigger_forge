resource "aws_sns_topic" "alert_topic" {
  name = "${var.project_prefix}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
  alarm_name          = "${var.project_prefix}-image-queue-depth-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  dimensions = {
    QueueName = aws_sqs_queue.image_queue.name
  }
  alarm_actions = [aws_sns_topic.alert_topic.arn]
}
HCL