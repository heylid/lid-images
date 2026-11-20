# lid-images

The container images that [Lid](https://heylid.dev)'s sandboxes run. Lid is a remote coding
agent: it runs commands and edits code in isolated machines, and a user can open a shell in
them. See [heylid.dev](https://heylid.dev) for Lid and its documentation.

There is one image for now, `sandbox`.

## The `sandbox` image

`ghcr.io/heylid/lid-sandbox`, **linux/amd64 only**, built from
[`images/sandbox/Dockerfile`](./images/sandbox/Dockerfile).

- **OS:** Ubuntu 24.04.
- **User:** `lid` (uid 1000, home `/home/lid`) with passwordless `sudo`, so you can install
  system packages (run `sudo apt-get update` before the first install: the package lists are
  not kept in the image). The image runs as `lid`.
- **Working directory:** `/workspace`, owned by `lid`.
- **Tools:** `git`, `gh`, `curl`, `ca-certificates`, `openssh-client`, `build-essential`,
  `ripgrep`, `fd` (`fdfind` on Ubuntu, linked as `fd`), `jq`, `unzip`, `zip`, `less`, `procps`,
  `nano`, `sudo`, Ubuntu's Python 3 with `pip` and `venv`, and Node.js LTS with `npm` and
  `npx`. No other runtimes (Rust, Go, Java...): they are installed when needed.
- **Trust store:** every tool reads the system bundle, `/etc/ssl/certs/ca-certificates.crt`.
  `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE`, `NODE_EXTRA_CA_CERTS`, `CURL_CA_BUNDLE`,
  `GIT_SSL_CAINFO` and `PIP_CERT` point at it, and `sudo` keeps them.
- **Entrypoint:** none; the default command is `bash`.

### Design

- **One image,** small on purpose: what is not needed by everyone is installed on demand.
- **Pinned by digest:** Lid refers to a released image by its digest, not by its tag.
- **Boots with no network:** nothing in the image needs to reach the network to start.
- **No CA baked in:** whoever runs the image may add a CA to the system bundle at start;
  because every tool reads that bundle, it is trusted everywhere.

## Using it locally

```sh
docker run --rm -it ghcr.io/heylid/lid-sandbox:<version>
```

To build it yourself:

```sh
docker build -t lid-sandbox:dev images/sandbox
images/sandbox/smoke-test.sh lid-sandbox:dev
```

## Versions and releases

- Pushing the tag `sandbox-vX.Y.Z` publishes `ghcr.io/heylid/lid-sandbox:X.Y.Z` and creates a
  GitHub release for the tag.
- **Versions are immutable:** a published version is never re-pushed, and the workflow refuses
  to overwrite one.
- **Digests** are in each [release's notes](https://github.com/heylid/lid-images/releases). Pin by digest: `ghcr.io/heylid/lid-sandbox@sha256:...`.
- Layers are gzip-compressed (checked in CI), for registries and runtimes that do not accept zstd.
- Images are not signed yet.
- **To cut a release** (maintainers): merge to `main`, then
  `git tag sandbox-vX.Y.Z && git push origin sandbox-vX.Y.Z`. The tag must be on `main`. The
  first time, make the package public in the organization's package settings. If a run fails
  after the push, run the release workflow by hand from `main` with the version: it looks up
  the existing image's digest and creates the release without pushing, after re-checking the image. If that check or the
  smoke test of the pushed image fails, cut a new version: the failed one is immutable.

Pull requests build the image without pushing it and run the smoke test.

## Layout

```
images/<name>/Dockerfile   one directory per image
images/<name>/smoke-test.sh
.github/workflows/         <name>-pr.yml and <name>-release.yml
```

A new image gets its own directory, workflows and tag prefix (`<name>-vX.Y.Z`).

## Security

Report vulnerabilities privately to **security@heylid.dev**, not in a public issue. See
[`SECURITY.md`](./SECURITY.md). The repository holds no secrets.

## Contributing

Outside pull requests are welcome; see [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Licence

[Apache-2.0](./LICENSE).
