#!/usr/bin/env bash
set -euxo pipefail

set +u
. /etc/profile
set -u

config_path="/etc/systemd/network/20-interfaces.network"

cat > "$config_path" <<EOF
[Match]
Name=ens* enp* eth*
[Network]
DHCP=yes
DNS=8.8.8.8
DNS=8.8.4.4
EOF

chmod 644 "$config_path"

resolv_path="/etc/resolv.conf"

cat >> "$resolv_path" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

systemctl enable systemd-networkd
systemctl restart systemd-resolved

# ping -c 4 google.com
