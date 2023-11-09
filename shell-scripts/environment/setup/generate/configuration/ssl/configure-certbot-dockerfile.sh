#!/bin/bash

configure_certbot_docker() {

  local CERTBOT_VERSION="2.7.4"

  cat <<EOF >"$CERTBOT_DIR/Dockerfile"
#base image
FROM python:3.10-alpine3.16 as certbot

ENTRYPOINT [ "certbot" ]
EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

# Retrieve certbot code
RUN mkdir -p src \
 && wget -O certbot-$CERTBOT_VERSION.tar.gz https://github.com/error-try-again/certbot/archive/refs/heads/master.zip \
 && tar xf certbot-$CERTBOT_VERSION.tar.gz \
 && cp certbot-$CERTBOT_VERSION/CHANGELOG.md certbot-$CERTBOT_VERSION/README.rst src/ \
 && cp -r certbot-$CERTBOT_VERSION/tools tools \
 && cp -r certbot-$CERTBOT_VERSION/acme src/acme \
 && cp -r certbot-$CERTBOT_VERSION/certbot src/certbot \
 && rm -rf certbot-$CERTBOT_VERSION.tar.gz certbot-$CERTBOT_VERSION

# Install certbot runtime dependencies
RUN apk add --no-cache --virtual .certbot-deps \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils

# We set this environment variable and install git while building to try and
# increase the stability of fetching the rust crates needed to build the
# cryptography library
ARG CARGO_NET_GIT_FETCH_WITH_CLI=true
# Install certbot from sources
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
        python3-dev \
        cargo \
        git \
        pkgconfig \
    && python tools/pip_install.py --no-cache-dir \
            --editable src/acme \
            --editable src/certbot \
    && apk del .build-deps \
    && rm -rf ${HOME}/.cargo
EOF
}
