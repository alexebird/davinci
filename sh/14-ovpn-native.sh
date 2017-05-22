#!/usr/bin/env bash

_ovpn_connect() {
  local env="${1:?must pass env}"
  local conf="${DAVINCI_ENV_PATH}/ovpn/${env}.ovpn"

  if [[ -z "$(_ovpn_pid ${env})" ]]; then
    sudo openvpn --config "${conf}" --daemon
  fi
}

_ovpn_pid() {
  local env="${1:?must pass env}"
  ps -ef | grep 'openvpn --config' | grep -v grep | grep "${env}" | awk '{print $2}'
}

_ovpn_cmd_up() {
  local env="${1:?must pass env}"
  _ovpn_connect "${env}"
  #while true ; do
  #done
}

_ovpn_cmd_down() {
  local env="${1:?must pass env}"
  sudo kill "$(_ovpn_pid ${env})"
}

davinci-ovpn-native-ls() {
  ps -ef | grep 'openvpn --config' | grep -v grep | grep --colour=never -oP -- "(?<=${DAVINCI_ENV_PATH}/ovpn/)(\w+)+(?=\.ovpn)" | sort
}

davinci-ovpn() {
  local env="${1:?must pass env}" ; shift
  local cmd="${1:?must pass up/down/reup}" ; shift
  _ovpn_cmd_"${cmd}" "${env}"
}
