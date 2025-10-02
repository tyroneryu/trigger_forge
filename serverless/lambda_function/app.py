import json
import boto3
import os


s3 = boto3.client('s3')


# 간단한 S3 이벤트 로그 핸들러


def lambda_handler(event, context):
processed = []
for record in event.get('Records', []):
s3_bucket = record['s3']['bucket']['name']
s3_key = record['s3']['object']['key']
print(f"Received S3 event. bucket={s3_bucket}, key={s3_key}")
# 실제 리사이징은 Pillow 같은 라이브러리로 확장 가능
processed.append({"bucket": s3_bucket, "key": s3_key})


return {
"statusCode": 200,
"body": json.dumps({"processed": processed})
}