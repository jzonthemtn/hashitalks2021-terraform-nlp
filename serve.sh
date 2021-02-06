#!/bin/bash
set -e

MODEL=${1:-"my-model"}

CLUSTER_NAME=`terraform output -raw ecs_cluster_name`
MODEL_BUCKET=`terraform output -raw s3_bucket`
ROLE_ARN=`terraform output -raw task_role_arn`
SUBNET_1=`terraform output -raw ml_vpc_subnet_id`
SUBNET_2=`terraform output -raw ml_vpc_subnet2_id`
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
  \"environment\": [
    {
      \"name\": \"MODEL_BUCKET\",
      \"value\": \"${MODEL_BUCKET}\"
    },
    {
      \"name\": \"MODEL_KEY\",
      \"value\": \"${MODEL_KEY}\"
    }
  ]
}]
"

# Create a task definition.
aws ecs register-task-definition \
  --family serving-${MODEL} \
  --container-definitions "$CONTAINER_DEFINITION"

# Create an ALB.
aws elbv2 create-load-balancer \
  --name $MODEL-lb \
  --subnets $SUBNET_1 $SUBNET_2 
  #--security-groups sg-07e8ffd50fEXAMPLE

# Create a service.
aws ecs create-service \
  --service-name serving-${MODEL} \
  --task-definition serving-${MODEL} \
  --desired-count 1 \
  --cluster $CLUSTER_NAME \
  --role $ROLE_ARN \
  --load-balancers loadBalancerName=$MODEL-lb,containerName=serving-${MODEL},containerPort=8080

# Expose it behind an ALB.
