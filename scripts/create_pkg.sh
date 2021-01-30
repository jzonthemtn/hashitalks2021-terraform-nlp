#!/bin/bash

# For reference: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html

set -e

rm -rf ./lamba_function/
mkdir -p ./lambda_function/

cp ./scripts/lambda_function.py ./lambda_function/
cp ./scripts/__init__.py ./lambda_function/

python3 -m pip install -r ./scripts/requirements.txt --target ./lambda_function/
