#!/bin/bash
set -e

MODEL=${1:-"my-model"}

CLUSTER_NAME=`terraform output -raw ecs_cluster_name`
MODEL_BUCKET=`terraform output -raw s3_bucket`
MODEL_KEY="${MODEL}/final-model.pt"

CONTAINER_DEFINITION="
[{
  \"name\": \"nlp-serving\",
  \"image\": \"jzemerick/ner-serving:latest\",
  \"portMappings\": [{
    \"containerPort\": 8080,
    \"hostPort\": 8080,
    \"protocol\": \"tcp\"
  }],
  \"logConfiguration\": {
    \"logDriver\": \"awslogs\",
    \"options\": {
        \"awslogs-group\": \"nlp-serving\",
        \"awslogs-region\": \"us-east-1\",
        \"awslogs-stream-prefix\": \"nlp-serving-${MODEL}\"
    }
},
  \"essential\": true,
  \"memory\": 4096,
  \"command\": [
    \"/bin/sh -c 'python3 /tmp/serve.py'\"
  ],
  \"environment\": [
    {
      \"name\": \"MODEL_BUCKET\",
      \"value\": \"${MODEL_BUCKET}\"
    },
    {
      \"name\": \"MODEL_BUCKET\",
      \"value\": \"${MODEL_KEY}\"
    }
  ]
}]
"

# Create a task definition.
aws ecs register-task-definition \
  --family serving-${MODEL} \
  --container-definitions "$CONTAINER_DEFINITION"

# Create a service.
aws ecs create-service \
  --service-name serving-${MODEL}-b \
  --task-definition serving-${MODEL} \
  --desired-count 1 \
  --cluster $CLUSTER_NAME

# Expose it behind an ALB.
