#!/bin/bash

_nomad_tunnel_pids() (set -euo pipefail
  if [[ -n "${NOMAD_PORT:-}" ]]; then
    ps -ef | grep ssh | grep "${NOMAD_PORT}:localhost" | awk '{print $2}'
  fi
)

_nomad_kill_tunnels() (set -euo pipefail
  local pids="$(_nomad_tunnel_pids)"
  if [[ -n "${pids}" ]]; then
    kill ${pids}
  fi
)

_random_port() {
    local port=$(gshuf -i 30000-35000 -n 1)
    netstat -nlt | grep -P "\.${port} " > /dev/null
    if [[ $? == 1 ]] ; then
        echo "${port}"
    else
        _random_port
    fi
}

_help_nomad-env() {
  cat <<HERE
Usage: ${1} ENV

This has autocompletion.

Sets NOMAD_ENV and other environment variables for use with nomad.
HERE
}

davinci-nomad-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="$1"
  local nomad_addr=''

  if [[ "${new_env}" == "unset" ]]; then
    _nomad_kill_tunnels
    unset NOMAD_ADDR
    unset NOMAD_ENV
    unset NOMAD_PORT
    unset CONSUL_HTTP_ADDR
    unset VAULT_ADDR

  else
    echo -n 'getting random port for ssh tunnel... '
    local port="$(_random_port)"
    echo "${port}"

    if ! davinci-aws-env > /dev/null; then
      echo "run: aws-env ${new_env}"
      return 1
    fi

    if [[ "${new_env}" != 'unset' ]] && ! davinci-ovpn-tb-is-up "${new_env}"; then
      echo "${new_env} vpn is not up"
      return 1
    fi

    echo -n 'grabbing the ip of a nomad server... '
    local ip="$(aws-find ec2 | grep running | grep -E 'master|instance-consul' | head -1 | cut -f1 -d' ')"
    echo "${ip}"

    if [[ -n "${ip}" ]]; then
      _nomad_kill_tunnels
      ssh -o StrictHostKeyChecking=no -fN -L${port}:localhost:4646 ubuntu@${ip}
      export NOMAD_ADDR="http://localhost:${port}"
      export NOMAD_ENV="${new_env}"
      export NOMAD_PORT="${port}"
      # some extra goodies. these probably do actually belong here...the tool itself needs renaming: HashiEnv
      export CONSUL_HTTP_ADDR="${ip}:8500"
      export CONSUL_RPC_ADDR="${ip}:8400"
      export VAULT_ADDR="https://vault.internal.${AWS_ENV}-${AWS_REGION}.aws.davinci.com"
    fi
  fi
}

if _lib_is_shell_bash; then
  complete -W'prod it dev unset' davinci-nomad-env
fi
