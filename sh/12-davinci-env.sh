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
    #echo "davinci-env dir doesn't exist '${curr_env_dir}'"
    return 1
  fi

  # unset all the exported vars
  unset DAVINCI_ENV

  for e in $(find "${curr_env_dir}" -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
    unset "${e}"
  done

  # TODO, unset the local env too
}

_davinci-env_source_sh_files() {
  local path="$1"

  for f in $(find "${path}" -type f -name '*.sh'); do
    . "${f}"
  done

  for f in $(find "${path}" -type f -name '*.sh.gpg'); do
    . <(gpg -d "${f}")
  done
}

_davinci-env_local_git_env_path() {
  local new_env="$1"
  local current_git_root
  local git_env_dir

  if ! _lib_git_assert_in_repo; then
    return 1
  fi

  current_git_root="$(_lib_git_top_level)"
  git_env_dir="${current_git_root}/davinci/env/${new_env}"

  if [[ -d "${git_env_dir}" ]]; then
    echo "${git_env_dir}"
    return 0
  else
    return 1
  fi
}

_davinci-env_print_env() {
  if [[ -n "${DAVINCI_ENV}" ]]; then
    echo "${DAVINCI_ENV}"
    return 0
  else
    return 1
  fi
}

davinci-davinci-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}"

  # first, maybe print the current env.
  if [[ -z "${new_env}" ]]; then
    _davinci-env_print_env
  fi

  # second, unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset

  # set the new env
  export DAVINCI_ENV="${new_env}"

  local global_env_dir="${DAVINCI_ENV_PATH}/${new_env}"
  local git_env_dir="$(_davinci-env_local_git_env_path "${new_env}")"

  if ! [[ -d "${global_env_dir}" ]] && ! [[ -d "${git_env_dir}" ]]; then
    echo "no davinci-env called '${new_env}'"
    return 1
  else
    if [[ -d "${global_env_dir}" ]]; then
      _davinci-env_source_sh_files "${global_env_dir}"
    fi

    if [[ -d "${git_env_dir}" ]]; then
      _davinci-env_source_sh_files "${git_env_dir}"
    fi
  fi
}
