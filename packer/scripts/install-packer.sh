#!/bin/bash

set -eu -o pipefail

PACKER_VERSION=0.11.0
PACKER_SHA256=318ffffa13763eb6f29f28f572656356dc3dbf8d54c01ffddd1c5e2f08593adb

wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -O /tmp/packer.zip
echo "$PACKER_SHA256 /tmp/packer.zip" | sha256sum --check --strict
sudo unzip -o /tmp/packer.zip -d /usr/bin

