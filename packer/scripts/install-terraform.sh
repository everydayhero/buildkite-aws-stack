#!/bin/bash

set -eu -o pipefail

TERRAFORM_VERSION=0.7.7
TERRAFORM_SHA256=478c4fe311392804ffc449995e8d7f903abab56f7483f317c1f120d8c21b1a81

wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
echo "$TERRAFORM_SHA256 /tmp/terraform.zip" | sha256sum --check --strict
sudo unzip /tmp/terraform.zip -d /usr/bin

