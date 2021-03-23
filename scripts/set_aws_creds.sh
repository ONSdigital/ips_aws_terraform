#!/bin/bash

set -euo pipefail

: "${TF_ENV}"
: "${SECRET_NAME}"

pushd terraform
  secret_value=$(terragrunt output -json concourse_secret_config | jq -r .)
popd

SECRET_KEY="${SECRET_NAME}" SECRET_VALUE="${secret_value}" ./scripts/create_secret.sh