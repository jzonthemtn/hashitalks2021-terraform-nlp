#!/bin/bash
set -e

CONTAINER_VERSION=${1:-"latest"}
MODEL_NAME_VERSION=${2:-"test-0.1"}
EPOCHS=${3:-"1"}
NER_MODELS_HOME=${4:-"/tmp"}
TRAINING_DIRECTORY="$NER_MODELS_HOME/models/$MODEL_NAME_VERSION"
S3_BUCKET=`terraform output -raw s3_bucket`

mkdir -p $TRAINING_DIRECTORY

docker run \
    --env "MODEL=my-model" \
    --env "EPOCHS=1" \
    --env "EMBEDDINGS=distilbert-base-cased" \
    --env "S3_BUCKET=$S3_BUCKET" \
    --rm \
    jzemerick/ner-training:$CONTAINER_VERSION

# --runtime=nvidia \
