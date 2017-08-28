# Everyday Hero Buildkite AWS Stack
Uses the official [Buildkite elastic CI stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) to provide a Docker-enabled, auto-scaling cloud of Buildkite agents. It's designed in a way so that Buildkite manages the entire environment with very little manual intervention.

The only manual task is the initial bootstrapping, configuring the pipeline, and triggering a build to create the other queues.

## What's different?
The official Buildkite stack is on a per-queue basis whilst we require multiple queues so CloudFormation is employed to provision multiple Buildkite stacks for each queue required. While the official stack can create a VPC it's limited because it hard-codes a CIDR block. It does allow specifying a VPC ID so to get around this limitation we provision the VPC and subnets for use by every stack. The other limitation is private hosts do not have access to the Internet by default and need to manually have networking configured.

S3 buckets are also provisioned for use by the stacks. One for build artefacts and another for secrets. The former is configured with a lifecycle rule so that objects are automatically purged after a specified duration has elapsed.

With the addition of a bootstrap script support it is no longer required to build a customised AMI. Instead the bootstrap script is used to install Ansible, Terraform, and Packer, on all build agents which already include Docker, Docker Compose, and AWS CLI.

All these extras are passed as arguments to Buildkite's CloudFormation template.

## What's in the box?

* A fresh VPC (CIDR 10.0.0.0/16)
* Private and public subnets, in two availability zones
* NATs in each availability zone so private hosts can access the Internet
* Artifact and secrets S3 buckets
* A maintenance queue (1x t2.nano host listening on queue=buildkite)

## Getting started
It's very easy to get a new cluster up and running.

1. Fork this repository
2. Log into your AWS account
3. In EC2, create a new Key Pair
4. In CloudFormation, create a new stack and upload `bootstrap.yml`
5. Fill in the parameters and continue to create
6. In Buildkite, create a new pipeline associated to your forked repository
7. Configure pipeline with environment variables, referencing output values from CloudFormation stack
8. Run pipeline
9. ...
10. Profit?

## Environment variables

Required variables for a cluster:
* `BUILDKITE_ORG_SLUG` - Your Buildkite organization's slug.
* `BUILDKITE_AGENT_TOKEN` - Your Buildkite organization's agent token.
* `BUILDKITE_API_ACCESS_TOKEN` - A Buildkite API access token (with read_pipelines, read_builds and read_agents) used for gathering metrics.
* `KEY_NAME` - The EC2 key name to use to access the EC2 hosts.
* `VPC_ID` - The VPC to use by each queue. Available as output value after running `bootstrap.yml`.
* `SUBNETS` - The subnets to use by each queue. Available as output value after running `bootstrap.yml`.
* `SECRETS_BUCKET` - The secrets bucket to use by each queue. Available as output value after running `bootstrap.yml`.
* `ARTIFACTS_BUCKET` - The artifacts bucket to use by each queue. Available as output value after running `bootstrap.yml`.

## Contributing
See [CONTRIBUTING.md](./.github/CONTRIBUTING.markdown).
