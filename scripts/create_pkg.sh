#!/bin/bash
set -e

python3 -m pip install -r ./scripts/requirements.txt --target ./lambda_function/
