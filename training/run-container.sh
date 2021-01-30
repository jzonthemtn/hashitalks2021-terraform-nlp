#!/bin/bash
set -e

CONTAINER_VERSION=${1:-"latest"}
MODEL_NAME_VERSION=${2:-"test-0.1"}
EPOCHS=${3:-"1"}
NER_MODELS_HOME=${4:-"/tmp/ner-train"}
TRAINING_DIRECTORY="$NER_MODELS_HOME/models/$MODEL_NAME_VERSION"

mkdir -p $TRAINING_DIRECTORY

# Pull the container from AWS ECR.
#eval $(aws ecr get-login --region us-east-1 --no-include-email)
#docker pull jzemerick/ner-train:$CONTAINER_VERSION
#docker logout

# Run the training in the container.
docker run \
    -v "$TRAINING_DIRECTORY:/philter-ner-train" \
    -v "$PHILTER_NER_MODELS_HOME/flair-data:/root/.flair" \
    --env "MODEL=my-model" \
    --env "EPOCHS=1" \
    --env "EMBEDDINGS=distilbert-base-cased" \
    --rm \
    jzemerick/ner-train:$CONTAINER_VERSION


# --runtime=nvidia \
