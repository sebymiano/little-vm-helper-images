#!/usr/bin/env bash
set -euxo pipefail

set +u
. /etc/profile
set -u

resolv_path="/etc/resolv.conf"

cat >> "$resolv_path" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# renovate: datasource=golang-version depName=go
GOLANG_VERSION=1.23.3
GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-$(dpkg --print-architecture).tar.gz

curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz
