#!/bin/bash

set -euo pipefail

fly_target="${FLY_TARGET:-socsur}"
concourse_team="${CONCOURSE_TEAM:-social-surveys}"

mkdir -p encrypted_secret

echo -n "${SECRET_VALUE}" | gcloud kms encrypt --project ons-ci --location europe-west2 --keyring concourse --key "${concourse_team}" --plaintext-file - --ciphertext-file - | base64 > encrypted_secret/secret

SECRET_KEY="${SECRET_KEY}" SECRET_NAME="${SECRET_NAME}" HTTPS_PROXY=localhost:8118 fly -t "${fly_target}" execute -c tasks/create_secret.yml -i encrypted_secret=encrypted_secret --include-ignored