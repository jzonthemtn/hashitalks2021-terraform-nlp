#!/bin/bash
set -e

MODEL=${1:-"my-model"}

CLUSTER_NAME=`terraform output -raw ecs_cluster_name`
S3_BUCKET=`terraform output -raw s3_bucket`
S3_URL="s3://${S3_BUCKET}/${MODEL}/"

# Create a task definition.
aws ecs register-task-definition \
  --family serving-${MODEL} \
  --container-definitions "[{\"name\":\"nlp-serving\",\"image\":\"jzemerick/nlp-serving:latest\",\"cpu\":1,\"command\":[\"sleep\",\"360\"],\"memory\":4096,\"essential\":true}]"

# Create a service.
aws ecs create-service \
  --service-name serving-${MODEL} \
  --task-definition serving-${MODEL} \
  --desired-count 1 \
  --cluster $CLUSTER_NAME

# Expose it behind an ALB.
