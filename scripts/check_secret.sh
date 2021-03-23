#!/bin/bash

set -euo pipefail

fly_target="${FLY_TARGET:-socsur}"

yq eval -i ".params.SECRET_VALUE = \"((${SECRET_NAME}.${SECRET_KEY}))\"" tasks/check_secret.yml

HTTPS_PROXY=localhost:8118 fly -t "${fly_target}" execute -c tasks/check_secret.yml