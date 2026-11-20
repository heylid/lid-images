# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG NODE_VERSION=26.13.1
ARG NODE_SHA256=5c063e46bab0fbc1c17cc445d7ff129cbdcd0471be6ed83b6ab864f8143bc864
ARG GH_VERSION=2.105.0
ARG GH_SHA256=79e7ab5db738c48777b696e374f8b428f0647debfb424f44d2f426370407fe2f

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential ca-certificates curl fd-find git jq less nano \
      openssh-client procps python3 python3-pip python3-venv ripgrep \
      sudo unzip xz-utils zip \
 && ln -s /usr/bin/fdfind /usr/local/bin/fd \
 && rm -rf /var/lib/apt/lists/*

# Node.js LTS (npm and npx included), from the official release tarball.
RUN curl -fsSL -o /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
 && echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c - \
 && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
      --exclude='*/CHANGELOG.md' --exclude='*/README.md' --exclude='*/LICENSE' \
      --exclude='*/share/doc' --exclude='*/share/man' --exclude='*/share/systemtap' --exclude='*/include' \
 && rm /tmp/node.tar.xz

# GitHub CLI, from the official release tarball.
RUN curl -fsSL -o /tmp/gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
 && echo "${GH_SHA256}  /tmp/gh.tar.gz" | sha256sum -c - \
 && tar -xzf /tmp/gh.tar.gz -C /usr/local --strip-components=1 \
      "gh_${GH_VERSION}_linux_amd64/bin/gh" \
 && rm /tmp/gh.tar.gz

# User "lid" (uid 1000) with passwordless sudo. The base image ships a user
# with uid 1000 already; it is replaced.
RUN userdel -r ubuntu \
 && useradd --uid 1000 --create-home --shell /bin/bash lid \
 && echo 'lid ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/lid \
 && echo 'Defaults env_keep += "SSL_CERT_FILE REQUESTS_CA_BUNDLE NODE_EXTRA_CA_CERTS CURL_CA_BUNDLE GIT_SSL_CAINFO PIP_CERT"' > /etc/sudoers.d/ca-env \
 && chmod 0440 /etc/sudoers.d/lid /etc/sudoers.d/ca-env \
 && mkdir /workspace \
 && chown lid:lid /workspace

# Every tool reads the system CA bundle, so a CA added to it at start is
# trusted everywhere. No CA is baked into the image.
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    PIP_CERT=/etc/ssl/certs/ca-certificates.crt

USER lid
WORKDIR /workspace
CMD ["/bin/bash"]
