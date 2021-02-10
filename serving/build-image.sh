#!/bin/bash
set -e

GIT_COMMIT=`git rev-parse --short HEAD`

docker build --label gitcommit="$GIT_COMMIT" -t $DOCKERHUB_USERNAME/ner-serving:latest .
