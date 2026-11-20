# Contributing

Outside pull requests are welcome.

## What belongs here

Changes to the images: their Dockerfiles, tests and publishing workflows. The `sandbox`
image is kept lean, so a new tool is weighed against the size it adds (report the unpacked
size change in your pull request). Runtimes such as Rust, Go or Java are deliberately not in
it; they are installed when needed.

## Build and test locally

```sh
docker build -t lid-sandbox:dev images/sandbox
images/sandbox/smoke-test.sh lid-sandbox:dev
```

The smoke test is what CI runs on every pull request. Extend it when you add something the
image promises.

## Dependencies

Dependabot bumps the GitHub Actions and the base image digest. Node.js and `gh` are downloaded
by the Dockerfile with pinned SHA256 checksums, so a bump of either needs its `*_VERSION` and
`*_SHA256` arguments updated by hand.

## Review

A maintainer reviews every pull request. CI runs on GitHub-hosted runners, and for a first-time
or outside contributor a maintainer must approve the workflow run before it starts.
Releases are cut by maintainers only.

## Licence

By contributing you agree that your contribution is licensed under the repository's licence,
[Apache-2.0](./LICENSE).
