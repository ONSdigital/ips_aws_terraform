#!/bin/bash

set -euo pipefail

## Installs
apk update
apk add jq python3 py3-pip
pip install awscli
## End Installs

/bin/entrypoint.sh

aws sts assume-role --role-arn $AWS_ROLE_ARN --role-session-name ips-concourse > /tmp/role_credentials.json
AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId /tmp/role_credentials.json)
AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey /tmp/role_credentials.json)
AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken /tmp/role_credentials.json)
AWS_DEFAULT_REGION="eu-west-2"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION

cd ips-ui-git/

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $ECR_REPO

docker build -t ips-ui .

docker tag ips-ui:latest $ECR_REPO/ips-ui:latest

docker push $ECR_REPO/ips-ui:latest