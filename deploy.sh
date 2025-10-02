#!/usr/bin/env bash
set -euo pipefail

# Terraform apply
cd terraform
terraform init
terraform apply -auto-approve

# Read outputs
QUEUE_ARN=$(terraform output -raw image_queue_arn)
BUCKET_NAME=$(terraform output -raw s3_bucket)
cd ../serverless

# SAM deploy (parameter overrides)
sam build
sam deploy --stack-name triggerforge-stack --capabilities CAPABILITY_IAM \
  --parameter-overrides ImageQueue=${QUEUE_ARN} UploadsBucket=${BUCKET_NAME}
SH
chmod +x deploy.sh