#!/bin/bash -eu

sudo yum update -y -q

for release in stable unstable experimental; do
  echo "Downloading buildkite-agent ${release}..."
  sudo curl -Lsf -o /usr/bin/buildkite-agent-${release} \
    "https://download.buildkite.com/agent/${release}/latest/buildkite-agent-linux-amd64"
  sudo chmod +x /usr/bin/buildkite-agent-${release}
  buildkite-agent-${release} --version
done

# move custom hooks into place
chmod +x /tmp/conf/hooks/*
sudo cp -a /tmp/conf/hooks/* /etc/buildkite-agent/hooks
sudo chown -R buildkite-agent: /etc/buildkite-agent/hooks
