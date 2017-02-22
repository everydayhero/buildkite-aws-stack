#!/bin/sh
echo "Fetching latest Buildkite AWS Stack template..."
curl -s -o ../aws-stack.json https://s3.amazonaws.com/buildkite-aws-stack/aws-stack.json
