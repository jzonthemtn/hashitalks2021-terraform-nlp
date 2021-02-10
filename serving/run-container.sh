#!/bin/bash

VERSION=${1:-latest}
S3_BUCKET=${2:-my-bucket}

docker run \
  --env "AWS_ACCESS_KEY_ID=***" \
  --env "AWS_SECRET_ACCESS_KEY=***" \
  --env "AWS_DEFAULT_REGION=us-east-1" \
  --env "MODEL_BUCKET=$S3_BUCKET" \
  -p 8080:8080 \
  -it \
  --rm \
  $DOCKERHUB_USERNAME/ner-serving:$VERSION
