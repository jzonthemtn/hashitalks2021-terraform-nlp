#!/bin/bash
set -e

QUEUE_URL=`terraform output -raw queue_url`
MODEL_NAME=${1:-"my-model"}

echo "Publishing message to SQS queue $QUEUE_URL"
aws sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body "{\"name\": \"$MODEL_NAME\", \"image\": \"$DOCKERHUB_USERNAME/ner-training:latest\", \"embeddings\": \"distilbert-base-cased\"}"
