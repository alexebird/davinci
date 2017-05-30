#!/bin/bash

# davinci-env: all-encompassing virtual env for infrastructure

_help_davinci-env() {
  cat <<HERE
Usage: ${1:?must pass cmdname} ENV

Sets the infrastructure virtual env.
HERE
}

_help_davinci-env-unset() {
  cat <<HERE
Usage: ${1:?must pass cmdname}

Clears the environment of all exported vars setup by a previous call of davinci-env.
HERE
}

davinci-davinci-env-unset() {
  local curr_env_dir="${DAVINCI_ENV_PATH}/${DAVINCI_ENV}"

  if [[ -z "${DAVINCI_ENV}" ]]; then
    return 0
  fi

  if ! [[ -d "${curr_env_dir}" ]]; then
    echo "davinci-env dir doesn't exist '${curr_env_dir}'"
    return 1
  fi

  # unset all the exported vars
  unset DAVINCI_ENV
  unset AWS_ENV

  for e in $(find "${curr_env_dir}" -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
    unset "${e}"
  done
}

davinci-davinci-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}"

  # first, maybe print the current env.
  if [[ -z "${new_env}" ]]; then
    if [[ -n "${DAVINCI_ENV}" ]]; then
      echo "${DAVINCI_ENV}"
      return 0
    else
      return 1
    fi
  fi

  # second, unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset

  #davinci-aws-env "${new_env}"
  local new_env_dir="${DAVINCI_ENV_PATH}/${new_env}"

  if ! [[ -d "${new_env_dir}" ]]; then
    echo "no davinci-env called '${new_env}'"
    return 1
  fi

  export DAVINCI_ENV="${new_env}"
  # i want to eventually get off AWS_ENV and only use DAVINCI_ENV
  export AWS_ENV="${DAVINCI_ENV}"

  for f in $(find "${new_env_dir}" -type f -name "*.sh"); do
    . "${f}"
  done
}
