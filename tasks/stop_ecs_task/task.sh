#!/bin/bash

set -euo pipefail

### Installs
pip install ec2instanceconnectcli

apt-get update -y
apt-get install -y jq curl unzip rsync ssh

mkdir -p /tmp/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/aws/awscliv2.zip"
pushd /tmp/aws
{
  unzip awscliv2.zip
  ./aws/install
}
popd
### END Installs

ECS_CLUSTER_NAME=$(jq -r '.sql_host' < terraform/metadata)
TASK_DEFINITON_UI=$(jq -r '.sql_password' < terraform/metadata)
TASK_DEFINITON_SERVICES=$(jq -r '.bastion_id' < terraform/metadata)

# Log into AWS
aws sts assume-role --role-arn $AWS_ROLE_ARN --role-session-name ips-concourse > /tmp/role_credentials.json
AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId /tmp/role_credentials.json)
AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey /tmp/role_credentials.json)
AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken /tmp/role_credentials.json)
AWS_DEFAULT_REGION="eu-west-2"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION


## Stop UI Task ID
OLD_TASK_ID=$(aws ecs list-tasks --cluster ${ECS_CLUSTER_NAME} --desired-status RUNNING --family ${TASK_DEFINITON_UI} | egrep "task/" | sed -E "s/.*task\/(.*)\"/\1/")
aws ecs stop-task --cluster ${ECS_CLUSTER_NAME} --task ${OLD_TASK_ID}

## Stop SERVICES Task ID
OLD_TASK_ID=$(aws ecs list-tasks --cluster ${ECS_CLUSTER_NAME} --desired-status RUNNING --family ${TASK_DEFINITON_SERVICES} | egrep "task/" | sed -E "s/.*task\/(.*)\"/\1/")
aws ecs stop-task --cluster ${ECS_CLUSTER_NAME} --task ${OLD_TASK_ID}