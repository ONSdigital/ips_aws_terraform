#!/bin/sh

set -eu

cd ips-repo/terraform_infrastructure/

terraform fmt -recursive -check