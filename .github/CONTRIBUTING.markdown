# Contributing

## Development

- Code should be written on feature branches.
- Feature branches should branch off `master`.
- Follow our [Git style guide](https://github.com/everydayhero/styleguide/blob/master/Git.md) closely.
- Push your branch to GitHub frequently, to avoid losing work.

## Continuous Integration

- The CI suite lives in [Buildkite](https://buildkite.com/everyday-hero/buildkite-aws-stack).

## Peer Review

- When ready, create a PR for your feature branch, pointing back into `master`.
- Mark your PR as a work-in-progress if it's not ready to be merged.
- It is your responsibility to find someone to review it.
- Discuss any feedback the reviewer has, and how you both want to proceed.
- Once you are both happy, the reviewer can merge your PR.

## Release

- Once merged into `master` the Terraform changes will be applied.
