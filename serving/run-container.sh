#!/bin/bash

VERSION=${1:-latest}

docker run \
  -e AWS_ACCESS_KEY_ID=*** \
  -e AWS_SECRET_ACCESS_KEY=*** \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -p 8080:8080 \
  -it \
  --rm \
  jzemerick/ner-serve:$VERSION
