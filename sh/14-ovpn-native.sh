#!/usr/bin/env bash

_ovpn_connect() {
  local env="$1"
  local conf="${DAVINCI_ENV_PATH}/${env}/client.ovpn"

  if [[ -z "$(_ovpn_pid ${env})" ]]; then
    sudo openvpn --config "${conf}" --daemon
  fi
}

_ovpn_ls() {
  local env="$1" ; shift
  local grep_flags="${1:-}" ; shift
  ps -ef \
    | grep 'openvpn --config' \
    | grep -v grep \
    | grep --colour=never -P ${grep_flags} "(?<=${DAVINCI_ENV_PATH}/)${env}(?=/client\.ovpn)"
}

_ovpn_pid() {
  local env="$1"
  _ovpn_ls "${env}" | awk '{print $2}'
}

_ovpn_cmd_up() {
  local env="$1"
  _ovpn_connect "${env}"
}

_ovpn_cmd_down() {
  local env="$1"
  sudo kill "$(_ovpn_pid ${env})"
}

_ovpn_cmd_reup() {
  local env="$1"
  _ovpn_cmd_down "${env}"
  sleep 7
  _ovpn_cmd_up "${env}"
}

davinci-ovpn-ls() {
  ps -ef \
    | grep 'openvpn --config' \
    | grep -v grep \
    | grep --colour=never -o -P ${grep_flags} "(?<=${DAVINCI_ENV_PATH}/).+(?=/client\.ovpn)"
}

davinci-ovpn-native-ls() {
  local env="${DAVINCI_ENV:?must set davinci-env}"
  _ovpn_ls "${env}" '-o' | sort
}

davinci-ovpn() {
  local cmd="${1:?must pass up/down/reup}" ; shift
  local env="${DAVINCI_ENV}"

  if [[ -z "${env}" ]]; then
    env="${1}"
  fi

  if [[ -z "${env}" ]]; then
    echo "must pass env or set DAVINCI_ENV"
    return 1
  fi

  _ovpn_cmd_"${cmd}" "${env}"
}
