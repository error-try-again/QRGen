#!/usr/bin/env bash
# bashsupport disable=BP5006,BP2001

set -euo pipefail

#######################################
# description
# Globals:
#   BASE_IMAGE
#   CARGO_NET_GIT_FETCH_WITH_CLI
#   CERTBOT_DOCKERFILE
#   DOCKERFILE_TEMPLATE
#   ENTRYPOINT
#   EXPOSE
#   HOME
#   VOLUMES
#   WORKDIR
# Arguments:
#  None
#######################################
configure_certbot_docker() {

BASE_IMAGE="python:3.10-alpine3.16 as certbot"
ENTRYPOINT="[ \"certbot\" ]"
EXPOSE="80 443"
VOLUMES="/etc/letsencrypt /var/lib/letsencrypt"
WORKDIR="/opt/certbot"
CARGO_NET_GIT_FETCH_WITH_CLI="true"

DOCKERFILE_TEMPLATE="FROM $BASE_IMAGE
ENTRYPOINT $ENTRYPOINT
EXPOSE $EXPOSE
VOLUME $VOLUMES
WORKDIR $WORKDIR

# Retrieve certbot code
RUN mkdir -p src \\
 && wget -O certbot-master.zip https://github.com/error-try-again/certbot/archive/refs/heads/master.zip \\
 && unzip certbot-master.zip \\
 && cp certbot-master/CHANGELOG.md certbot-master/README.rst src/ \\
 && cp -r certbot-master/tools tools \\
 && cp -r certbot-master/acme src/acme \\
 && cp -r certbot-master/certbot src/certbot \\
 && rm -rf certbot-master.tar.gz certbot-master

# Install certbot runtime dependencies
RUN apk add --no-cache --virtual .certbot-deps \\
        libffi \\
        libssl1.1 \\
        openssl \\
        ca-certificates \\
        binutils

# We set this environment variable and install git while building to try and
# increase the stability of fetching the rust crates needed to build the
# cryptography library
ARG CARGO_NET_GIT_FETCH_WITH_CLI=$CARGO_NET_GIT_FETCH_WITH_CLI

# Install certbot from sources
RUN apk add --no-cache --virtual .build-deps \\
        gcc \\
        linux-headers \\
        openssl-dev \\
        musl-dev \\
        libffi-dev \\
        python3-dev \\
        cargo \\
        git \\
        pkgconfig \\
    && python tools/pip_install.py --no-cache-dir \\
            --editable src/acme \\
            --editable src/certbot \\
    && apk del .build-deps \\
    && rm -rf \"${HOME}\"/.cargo"

  echo -e "$DOCKERFILE_TEMPLATE" > "$CERTBOT_DOCKERFILE"
  cat "$CERTBOT_DOCKERFILE"
}
