#!/bin/bash

set -eu -o pipefail

TERRAFORM_VERSION=0.7.2
TERRAFORM_SHA256=b337c885526a8a653075551ac5363a09925ce9cf141f4e9a0d9f497842c85ad5

wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
echo "$TERRAFORM_SHA256 /tmp/terraform.zip" | sha256sum --check --strict
sudo unzip /tmp/terraform.zip -d /usr/bin

