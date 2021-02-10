#!/bin/bash
set -e

GIT_COMMIT=`git rev-parse --short HEAD`
FLAIR_VERSION="0.7"

docker build --build-arg FLAIR_VERSION=$FLAIR_VERSION --label gitcommit="$GIT_COMMIT" -t $DOCKERHUB_USERNAME/ner-training:latest .
