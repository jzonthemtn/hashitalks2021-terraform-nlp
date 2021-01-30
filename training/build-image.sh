#!/bin/bash
set -e

GIT_COMMIT=`git rev-parse --short HEAD`
FLAIR_VERSION="0.7"

DOCKERHUB_TOKEN=`aws ssm get-parameter --region us-east-1 --name dockerhub_token | jq -r .Parameter.Value`
echo $DOCKERHUB_TOKEN | docker login --username jzemerick --password-stdin

docker build --build-arg FLAIR_VERSION=$FLAIR_VERSION --label gitcommit="$GIT_COMMIT" -t jzemerick/ner-train:latest .
#docker push jzemerick/ner-train:latest

docker logout
