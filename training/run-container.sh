#!/bin/bash
set -e

CONTAINER_VERSION=${1:-"latest"}
MODEL_NAME_VERSION=${2:-"test-0.1"}
EPOCHS=${3:-"1"}
S3_BUCKET=`terraform output -raw s3_bucket`

docker run \
    --env "MODEL=$MODEL_NAME_VERSION" \
    --env "EPOCHS=1" \
    --env "EMBEDDINGS=distilbert-base-cased" \
    --env "S3_BUCKET=$S3_BUCKET" \
    --rm \
    $DOCKERHUB_USERNAME/ner-training:$CONTAINER_VERSION

# --runtime=nvidia \
