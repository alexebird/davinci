#!/usr/bin/env bash

_ovpn_connect() {
  local env="$1"
  # TODO the path prefix shouldn't be hardcoded, but it is required as of writing due to
  # the addition of the support of multiple paths in DAVINCI_ENV_PATH
  local conf="${DAVINCI_HOME}/.davinci-env/${env}/client.ovpn"

  if [[ -z "$(_ovpn_pid ${env})" ]]; then
    sudo openvpn --config "${conf}" --daemon
  fi
}

_ovpn_ls() {
  local env="$1" ; shift
  #local grep_flags="${1:-}" ; shift
  # TODO the path prefix shouldn't be hardcoded, but it is required as of writing due to
  # the addition of the support of multiple paths in DAVINCI_ENV_PATH
  ps -ef \
    | grep 'openvpn --config' \
    | grep -v grep \
    | grep --colour=never -P "${HOME}/\.davinci-env/.*${env}/client\.ovpn"
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

_ovpn_cmd_ls() {
  local env="${1:-}"
  # TODO the path prefix shouldn't be hardcoded, but it is required as of writing due to
  # the addition of the support of multiple paths in DAVINCI_ENV_PATH
  #ps -ef \
    #| grep 'openvpn --config' \
    #| grep -v grep \
    #| grep --colour=never -o -P ${grep_flags} "(?<=${DAVINCI_ENV_PATH}/).+(?=/client\.ovpn)"
  _ovpn_ls "${env}" \
    | grep -oP '(?<=davinci-env/).+(?=/client)' \
    | sort
}

#_ovpn_cmd_nls() {
  #local env="${1:-}"
  #_ovpn_ls "${env}" | sort
#}

davinci-ovpn() {
  local cmd="${1:?must pass up/down/reup}" ; shift
  local env_override="${1:-}" ; shift
  local env="${DAVINCI_ENV}"

  if [[ -n "${env_override}" ]]; then
    env="${env_override}"
  fi

  #if [[ -z "${env}" ]]; then
    #echo "must pass env or set DAVINCI_ENV"
    #return 1
  #fi

  _ovpn_cmd_"${cmd}" "${env}"
}
