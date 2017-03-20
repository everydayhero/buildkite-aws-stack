provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "buildkite_artifacts" {
  bucket = "${var.name}-artifacts"
  acl = "private"
  force_destroy = true

  lifecycle_rule {
    prefix = "*"
    enabled = true

    expiration {
      days = "${var.artifact_retention}"
    }
  }
}

resource "aws_s3_bucket" "buildkite_secrets" {
  bucket = "${var.name}-secrets"
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "bootstrap_script" {
  bucket = "${aws_s3_bucket.buildkite_secrets.id}"
  key = "bootstrap"
  source = "scripts/bootstrap"
  content_type = "plain/text"
  acl = "public-read"
}

resource "aws_vpc" "buildkite" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "private" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  vpc_id = "${aws_vpc.buildkite.id}"
  availability_zone = "${element(split(",", coalesce(var.availability_zones, var.region)), count.index)}"
  cidr_block = "${cidrsubnet(aws_vpc.buildkite.cidr_block, 8, count.index)}"

  tags {
    Name = "${var.name}-private-${element(split(",", coalesce(var.availability_zones, var.region)), count.index)}"
  }
}

resource "aws_subnet" "public" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  vpc_id = "${aws_vpc.buildkite.id}"
  availability_zone = "${element(split(",", coalesce(var.availability_zones, var.region)), 0)}"
  cidr_block = "${cidrsubnet(aws_vpc.buildkite.cidr_block, 8, count.index+length(split(",", coalesce(var.availability_zones, var.region))))}"

  depends_on = ["aws_internet_gateway.buildkite"]

  tags {
    Name = "${var.name}-public-${element(split(",", coalesce(var.availability_zones, var.region)), count.index)}"
  }
}

resource "aws_internet_gateway" "buildkite" {
  vpc_id = "${aws_vpc.buildkite.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_eip" "nat" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  vpc = true
}

resource "aws_nat_gateway" "public" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  vpc_id = "${aws_vpc.buildkite.id}"

  route {
    nat_gateway_id = "${element(aws_nat_gateway.public.*.id, count.index)}"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.name}-private-${element(split(",", coalesce(var.availability_zones, var.region)), count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.buildkite.default_route_table_id}"

  route {
    gateway_id = "${aws_internet_gateway.buildkite.id}"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(split(",", coalesce(var.availability_zones, var.region)))}"
  route_table_id = "${aws_vpc.buildkite.default_route_table_id}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_cloudformation_stack" "buildkite" {
  name = "${var.name}Stack"
  template_body = "${file("deprecated-aws-stack.json")}"
  capabilities = ["CAPABILITY_IAM"]

  parameters {
    KeyName = "${var.key_name}"
    ImageId = "ami-df6247c8"
    BuildkiteOrgSlug = "${var.buildkite_org_slug}"
    BuildkiteAgentToken = "${var.buildkite_agent_token}"
    BuildkiteQueue = "elastic"
    BuildkiteApiAccessToken = "${var.buildkite_api_access_token}"
    SecretsBucket = "${aws_s3_bucket.buildkite_secrets.id}"
    ArtifactsBucket = "${aws_s3_bucket.buildkite_artifacts.id}"
    InstanceType = "t2.large"
    MaxSize = "20"
    MinSize = "0"
    RootVolumeSize = "100"
    AvailabilityZones = "${coalesce(var.availability_zones, var.region)}"
    ScheduledDownscale = "0 14 * * *"
  }
}

resource "aws_cloudformation_stack" "buildkite_queue" {
  count = "${length(var.queue)}"
  name = "${var.name}-${element(var.queue, count.index)}-stack"
  template_url = "https://s3.amazonaws.com/buildkite-aws-stack/aws-stack.json"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  parameters {
    KeyName = "${var.key_name}"
    BuildkiteAgentRelease = "${var.buildkite_agent_release}"
    BuildkiteOrgSlug = "${var.buildkite_org_slug}"
    BuildkiteAgentToken = "${var.buildkite_agent_token}"
    BuildkiteQueue = "${element(var.queue, count.index)}"
    BuildkiteApiAccessToken = "${var.buildkite_api_access_token}"
    BootstrapScriptUrl = "http://${aws_s3_bucket.buildkite_secrets.id}.s3.amazonaws.com/${aws_s3_bucket_object.bootstrap_script.id}"
    SecretsBucket = "${aws_s3_bucket.buildkite_secrets.id}"
    ArtifactsBucket = "${aws_s3_bucket.buildkite_artifacts.id}"
    InstanceType = "${lookup(var.instance_type, element(var.queue, count.index), var.default_instance_type)}"
    ManagedPolicyARN = "${lookup(var.managed_policy_arn, element(var.queue, count.index), "")}"
    MaxSize = "${lookup(var.max_size, element(var.queue, count.index), var.default_max_size)}"
    MinSize = "${lookup(var.min_size, element(var.queue, count.index), var.default_min_size)}"
    RootVolumeSize = "${lookup(var.volume_size, element(var.queue, count.index), var.default_volume_size)}"
    AgentsPerInstance = "${lookup(var.agents_per_instance, element(var.queue, count.index), var.default_agents_per_instance)}"
    ScaleUpAdjustment = "${lookup(var.scale_up_adjustment, element(var.queue, count.index), var.default_scale_up_adjustment)}"
    ScaleDownAdjustment = "${lookup(var.scale_down_adjustment, element(var.queue, count.index), var.default_scale_down_adjustment)}"
    VpcId = "${aws_vpc.buildkite.id}"
    Subnets = "${join(",", aws_subnet.private.*.id)}"
    AssociatePublicIpAddress = "false"
  }
}

output "secrets_bucket" {
  value = "${aws_s3_bucket.buildkite_secrets.id}"
}

output "artifacts_bucket" {
  value = "${aws_s3_bucket.buildkite_artifacts.id}"
}
