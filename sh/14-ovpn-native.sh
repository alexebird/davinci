#!/usr/bin/env bash

_ovpn_connect() {
  local env="$1"
  local conf="${DAVINCI_ENV_PATH}/${env}/config.ovpn"

  if [[ -z "$(_ovpn_pid ${env})" ]]; then
    sudo openvpn --config "${conf}" --daemon
  fi
}

_ovpn_pid() {
  local env="$1"
  ps -ef | grep 'openvpn --config' | grep -v grep | grep "${env}" | awk '{print $2}'
}

_ovpn_cmd_up() {
  local env="$1"
  _ovpn_connect "${env}"
  #while true ; do
  #done
}

_ovpn_cmd_down() {
  local env="$1"
  sudo kill "$(_ovpn_pid ${env})"
}

davinci-ovpn-native-ls() {
  ps -ef \
    | grep 'openvpn --config' \
    | grep -v grep \
    | grep --colour=never -oP -- "(?<=${DAVINCI_ENV_PATH}/${DAVINCI_ENV}/)(\w+)+(?=\.ovpn)" \
    | sort
}

davinci-ovpn() {
  local cmd="${1:?must pass up/down/reup}" ; shift
  local env="${DAVINCI_ENV:?must set davinci-env}"
  _ovpn_cmd_"${cmd}" "${env}"
}
