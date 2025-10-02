import json
import os
import boto3
from PIL import Image
from io import BytesIO
import logging
import time

s3 = boto3.client('s3')
cloudwatch = boto3.client('cloudwatch')

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

THUMB_PREFIX = os.getenv('THUMB_PREFIX', 'thumbnails/')
THUMB_SIZE = int(os.getenv('THUMB_SIZE', '256'))

def emit_metric(name, value, unit='Count'):
    try:
        cloudwatch.put_metric_data(
            Namespace='TriggerForge/ImageProcessing',
            MetricData=[{'MetricName': name, 'Value': value, 'Unit': unit}]
        )
    except Exception as e:
        LOG.warning("Failed to emit metric: %s", e)

def process_s3_object(bucket, key):
    resp = s3.get_object(Bucket=bucket, Key=key)
    body = resp['Body'].read()
    img = Image.open(BytesIO(body)).convert('RGB')
    img.thumbnail((THUMB_SIZE, THUMB_SIZE))
    out_buf = BytesIO()
    img.save(out_buf, format='JPEG')
    out_buf.seek(0)
    thumb_key = THUMB_PREFIX + key.split('/')[-1]
    s3.put_object(Bucket=bucket, Key=thumb_key, Body=out_buf, ContentType='image/jpeg')
    return thumb_key

def lambda_handler(event, context):
    start = time.time()
    processed = 0
    for record in event.get('Records', []):
        # SQS -> body contains S3 event JSON as string
        body = json.loads(record['body'])
        for rec in body.get('Records', []):
            try:
                bucket = rec['s3']['bucket']['name']
                key = rec['s3']['object']['key']
                LOG.info("Processing s3://%s/%s", bucket, key)
                thumb = process_s3_object(bucket, key)
                LOG.info("Wrote thumbnail: %s", thumb)
                processed += 1
            except Exception as e:
                LOG.exception("Failed to process record: %s", e)
                # raise to let SQS/Lambda handle retries / DLQ
                raise
    duration = time.time() - start
    emit_metric('ProcessedCount', processed)
    emit_metric('ProcessingDurationMs', int(duration * 1000), unit='Milliseconds')
    return {"statusCode": 200, "processed": processed}
PY