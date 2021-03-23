#!/bin/bash

set -euo pipefail

: "${TF_ENV}"

pushd terraform
  # Terragrunt cache can cause issues when switching enviornments, easier to just remove it each time
  rm -rf .terragrunt-cache
  terragrunt apply -auto-approve
popd
