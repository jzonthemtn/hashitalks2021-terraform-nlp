#!/bin/bash

VERSION=${1:-latest}

docker run \
  -p 18080:18080 \
  -it \
  --rm \
  jzemerick/ner-serve:$VERSION
