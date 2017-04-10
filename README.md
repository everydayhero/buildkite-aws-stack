# Everyday Hero Buildkite AWS Stack
Uses the official [Buildkite elastic CI stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) to provide a Docker-enabled, auto-scaling cloud of Buildkite agents. Terraform is used to not only manage provisioning of the stack but fascilitate customisations.

## What's different?
The official Buildkite stack is on a per-queue basis whilst we require multiple queues so Terraform is employed to provision multiple Buildkite stacks for each queue required. It also provisions VPCs, private Subnets, and configures all the routing tables etc so that the stacks are in the same VPC.

S3 buckets are also provisioned for use by the stacks. One for build artefacts and another for secrets. The former is configured with a lifecycle rule so that objects are automatically purged after a specified duration has elapsed.

With the addition of a bootstrap script support it is no longer required to build a customised AMI. Instead the bootstrap script is used to install Ansible, Terraform, and Packer, on all build agents which already include Docker, Docker Compose, and AWS CLI.

All these extras are passed as arguments to Buildkite's CloudFormation template.

## Getting started
It's very easy to get a new cluster up and running. Before commencing ensure you have [Terraform](https://terraform.io) installed.

1. Clone this repository `git clone git@github.com:everydayhero/buildkite-aws-stack.git`
2. Run `terraform init` to initialize Terraform
3. Run `terraform plan -out planfile` to outline all the changes to be made (look below for available variables)
4. Run `terraform apply planfile` to provision the cluster
5. ...
6. Profit?

## Variables
To use variables read [Terraform's documentation](https://www.terraform.io/docs/configuration/variables.html). Environment variables or variable files are recommended.

Required variables for a cluster:
* `buildkite_org_slug` - Your Buildkite organization's slug
* `buildkite_agent_token` - Your Buildkite organization's agent token
* `buildkite_api_access_token` - A Buildkite API access token (with read_pipelines, read_builds and read_agents) used for gathering metrics

Optional variables:
* `access_key` - The AWS access key
* `secret_key` - The AWS secret key
* `region` - The AWS region
* `name` - Name of the stack (default: `buildkite`)
* `queue` - List of queue names (default: `["default"]`)
* `artifact_retention` - Number of days to retain artifacts (default: `9`)
* `availability_zones` - The availability zones for the subnets (defaults to region)
* `cidr_block` - The CIDR block to use for the VPC (default: `10.0.0.0/16`)
* `buildkite_agent_release` - The agent release to use (default: `stable`)

Per queue variables (must be specify queue name along with value. ie. `{ queue_name = "value" }`):
* `instance_type` - The default type of instance to use for the agent
* `max_size` - The default maximum number of agents to launch
* `min_size` - The default minumum number of agents to launch
* `volume_size` - Default size of EBS volume for root filesystem in GB
* `agents_per_instance` - Default number of Buildkite agents to run on each instance
* `scale_up_adjustment` - Default number of instances to add on scale up events
* `scale_down_adjustment` - Default number of instances to remove on scale down events

Default variables for all queues:
* `default_instance_type` - The default type of instance to use for the agent (default: `m3.medium`)
* `default_max_size` - The default maximum number of agents to launch (default: `10`)
* `default_min_size` - The default minumum number of agents to launch (default: `0`)
* `default_volume_size` - Default size of EBS volume for root filesystem in GB (default: `250`)
* `default_agents_per_instance` - Default number of Buildkite agents to run on each instance (default: `1`)
* `default_scale_up_adjustment` - Default number of instances to add on scale up events (default: `5`)
* `default_scale_down_adjustment` - Default number of instances to remove on scale down events (default: `-1`)
