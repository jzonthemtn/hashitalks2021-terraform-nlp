#!/bin/bash

VERSION=${1:-latest}

docker run \
  --env AWS_ACCESS_KEY_ID=*** \
  --env AWS_SECRET_ACCESS_KEY=*** \
  --env AWS_DEFAULT_REGION=us-east-1 \
  --env BUCKET=mtnfog-temp \
  -p 8080:8080 \
  -it \
  --rm \
  jzemerick/ner-serve:$VERSION
