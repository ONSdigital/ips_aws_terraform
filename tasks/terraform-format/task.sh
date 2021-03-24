#!/bin/sh

set -eu

cd ips-repo/terraform-infrastructure/

terraform fmt -recursive -check