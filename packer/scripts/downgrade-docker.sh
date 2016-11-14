#!/bin/bash

set -eu -o pipefail

# Manual install ala https://docs.docker.com/engine/installation/binaries/
curl -Lsf https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz > docker-1.11.2.tgz
tar -xvzf docker-1.11.2.tgz
sudo service docker stop

sudo mv docker/* /usr/bin
cat <<EOF | sudo tee /etc/sysconfig/docker
DAEMON_MAXFILES=1048576
OPTIONS="--default-ulimit nofile=1024:4096 -s overlay"
EOF

sudo service docker start
