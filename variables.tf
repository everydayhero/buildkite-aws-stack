variable "access_key" {
  default = ""
  description = "The AWS access key"
}

variable "secret_key" {
  default = ""
  description = "The AWS secret key"
}

variable "region" {
  default = "us-east-1"
  description = "The AWS region"
}

variable "name" {
  description = "Name of the stack"
  default = "buildkite"
}

variable "key_name" {
  description = "The ssh keypair used to access the buildkite instances"
}

variable "buildkite_agent_release" {
  default = "stable"
}

variable "buildkite_org_slug" {
  description = "Your Buildkite organization's slug"
}

variable "buildkite_agent_token" {
  description = "Your Buildkite organization's agent token"
}

variable "buildkite_api_access_token" {
  description = "A Buildkite API access token (with read_pipelines, read_builds and read_agents) used for gathering metrics"
}

variable "queue" {
  type = "list"
  default = ["default"]
}

variable "instance_type" {
  type = "map"
  description = "The type of instance to use for the agent"
  default = {}
}

variable "default_instance_type" {
  description = "The default type of instance to use for the agent"
  default = "m3.medium"
}

variable "managed_policy_arn" {
  type = "map"
  description = "Optional managed IAM policy to attach to the instance role"
  default = {}
}

variable "max_size" {
  type = "map"
  description = "The maximum number of agents to launch"
  default = {}
}

variable "default_max_size" {
  description = "The default maximum number of agents to launch"
  default = 10
}

variable "min_size" {
  type = "map"
  description = "The minumum number of agents to launch"
  default = {}
}

variable "default_min_size" {
  description = "The default minumum number of agents to launch"
  default = 0
}

variable "volume_size" {
  type = "map"
  description = "Size of EBS volume for root filesystem in GB"
  default = {}
}

variable "default_volume_size" {
  description = "Default size of EBS volume for root filesystem in GB"
  default = 250
}

variable "agents_per_instance" {
  type = "map"
  description = "Number of Buildkite agents to run on each instance"
  default = {}
}

variable "default_agents_per_instance" {
  description = "Default number of Buildkite agents to run on each instance"
  default = 1
}

variable "scale_up_adjustment" {
  type = "map"
  description = "Number of instances to add on scale up events (ScheduledJobsCount > 0 for 1 min)"
  default = {}
}

variable "default_scale_up_adjustment" {
  description = "Default number of instances to add on scale up events (ScheduledJobsCount > 0 for 1 min)"
  default = 5
}

variable "scale_down_adjustment" {
  type = "map"
  description = "Number of instances to remove on scale down events (UnfinishedJobs == 0 for 30 mins)"
  default = {}
}

variable "default_scale_down_adjustment" {
  description = "Default number of instances to remove on scale down events (UnfinishedJobs == 0 for 30 mins)"
  default = -1
}

variable "artifact_retention" {
  description = "Number of days to retain artifacts"
  default = 9
}

variable "availability_zones" {
  description = "The availability zones for the subnets. Defaults to region."
  default = ""
}

variable "cidr_block" {
  description = "The CIDR block to use for the VPC. Defaults to 10.0.0.0/16."
  default = "10.0.0.0/16"
}
