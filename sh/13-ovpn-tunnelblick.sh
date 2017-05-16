#!/bin/bash

davinci-ovpn-tb-ls() (set -euo pipefail
  ps -ef | \
    grep openvpn | \
    grep -v grep | \
    grep --colour=never -oP -- "(\w+-)+\d+(?=\.tblk/Contents/Resources/config.ovpn)" | \
    sort
)

davinci-ovpn-tb-is-up() (set -euo pipefail
  local vpn="${1:?must pass vpn}"
  davinci-ovpntb-ls | grep -q "${vpn}"
)
