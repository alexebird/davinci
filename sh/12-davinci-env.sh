#!/bin/bash

# davinci-env: all-encompassing virtual env for infrastructure

_help_davinci-env() {
  cat <<HERE
Usage: ${1:?must pass cmdname} ENV

Sets the infrastructure virtual env.
HERE
}

davinci-davinci-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}"

  if [[ -z "${new_env}" ]]; then
    echo "${DAVINCI_ENV}"
    return 0
  fi

  davinci-aws-env "${new_env}"
  export DAVINCI_ENV="${new_env}"
}
