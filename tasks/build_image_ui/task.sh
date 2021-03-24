#!/bin/bash

set -euo pipefail

## Installs
pip install awscli

pip install docker
## End Installs

ECR_REPO=$(jq -r '.ecr_repo' < terraform/metadata)

cd ips-ui-git/

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $ECR_REPO

docker build -t ips-ui .

docker tag ips-ui:latest $ECR_REPO/ips-ui:latest

docker push $ECR_REPO/ips-ui:latest