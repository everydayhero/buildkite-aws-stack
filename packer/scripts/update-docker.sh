#!/bin/bash

set -eu -o pipefail

sudo yum update -y -q

echo "Installing docker..."

# Only dep to install (found by doing a yum install of 1.11)
sudo yum install -y xfsprogs

# Manual install ala https://docs.docker.com/engine/installation/binaries/
sudo service docker stop
curl -Lsf https://get.docker.com/builds/Linux/x86_64/docker-1.12.3.tgz > docker-1.12.3.tgz
tar -xvzf docker-1.12.1.tgz
sudo rm -rf /var/lib/docker
sudo mv docker/* /usr/bin
sudo service docker start

echo "Downloading docker-compose..."
sudo rm /usr/bin/docker-compose
sudo curl -Lsf -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.8.1/docker-compose-Linux-x86_64
sudo chmod +x /usr/bin/docker-compose
docker-compose --version
