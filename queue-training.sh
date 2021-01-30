#!/bin/bash
set -e
QUEUE_URL=`terraform output -raw queue_url`

echo "Publishing message to SQS queue $QUEUE_URL"
aws sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body '{"name": "my-model"}'
