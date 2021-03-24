#!/bin/sh

set -eu

cd ips-repo/infrastructure/

terraform fmt -recursive -check