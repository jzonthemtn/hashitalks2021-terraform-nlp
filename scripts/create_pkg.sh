#!/bin/bash
set -e

rm -rf ./lambda_dist_pkg
mkdir lambda_dist_pkg

python3 -m venv ./lambda_dist_pkg/venv
source lambda_dist_pkg/venv/bin/activate
python3 -m pip install -r ./lambda_function/requirements.txt
deactivate

cp -r lambda_dist_pkg/venv/lib/python3.8/site-packages/ ./lambda_dist_pkg/
