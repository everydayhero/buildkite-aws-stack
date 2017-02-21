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
    ScheduledDownscale = "${var.scheduled_downscale}"
  }
}

resource "aws_cloudformation_stack" "buildkite_queue" {
  count = "${length(var.queue)}"
  name = "${var.name}-${element(var.queue, count.index)}-stack"
  template_body = "${file("aws-stack.json")}"
  capabilities = ["CAPABILITY_IAM"]

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
    InstanceType = "${var.instance_type}"
    MaxSize = "${var.max_size}"
    MinSize = "${var.min_size}"
    RootVolumeSize = "${var.volume_size}"
    AvailabilityZones = "${coalesce(var.availability_zones, var.region)}"
    ScheduledDownscale = "${var.scheduled_downscale}"
  }
}

output "secrets_bucket" {
  value = "${aws_s3_bucket.buildkite_secrets.id}"
}

output "artifacts_bucket" {
  value = "${aws_s3_bucket.buildkite_artifacts.id}"
}
