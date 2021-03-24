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

SQL_HOST=$(jq -r '.sql_host' < terraform/metadata)
SQL_PASSWORD=$(jq -r '.sql_password' < terraform/metadata)
BASTION_ID=$(jq -r '.bastion_id' < terraform/metadata)

aws sts assume-role --role-arn $AWS_ROLE_ARN --role-session-name spp-crosscutting-concourse > /tmp/role_credentials.json
AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId /tmp/role_credentials.json)
AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey /tmp/role_credentials.json)
AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken /tmp/role_credentials.json)
AWS_DEFAULT_REGION="eu-west-2"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION

echo "mysql -h ${SQL_HOST} -u ${SQL_USER:-root} -p${SQL_PASSWORD} -D ips -e 'SHOW TABLES;" >/tmp/db_cmd.sh

TABLES=$(mssh "${BASTION_ID}" "bash -s" < /tmp/db_cmd.sh)

echo "Tables: ${TABLES}"

if [ "${TABLES}" = "" ]; then
  echo "Importing schema"
  rsync -a -e "mssh" "ips-service-git/db/data/ips_mysql_schema.sql" "${BASTION_ID}:/tmp/sql_schema"
  echo "mysql -h ${SQL_HOST} -u ${SQL_USER:-root} -p${SQL_PASSWORD} -D ips < /tmp/sql_schema" >/tmp/sql_dump.sh

  mssh "${BASTION_ID}" "bash -s" < /tmp/sql_dump.sh
else
  echo "Not importing schema as tables already exist"
fi
