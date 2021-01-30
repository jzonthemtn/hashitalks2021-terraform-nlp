#!/bin/bash
set -e
QUEUE_URL=`terraform output -raw queue_url`

echo "Publishing message to SQS queue $QUEUE_URL"
