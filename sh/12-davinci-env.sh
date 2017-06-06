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

davinci-env::unset_at_path() {
  local path_="$1"

  if ! [[ -d "${path_}" ]]; then
    return 1
  fi

  for v in $(find "${path_}" -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
    unset "${v}"
  done

  for e in $(find "${path_}" -type f -name "*.sh.gpg"); do
    for v in $(gpg -d "${e}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
      unset "${v}"
    done
  done
}

davinci-davinci-env-unset() {
  local curr_env_dir="${DAVINCI_ENV_PATH}/${DAVINCI_ENV}"
  local git_env_dir="$(davinci-env::local_git_env_path "${DAVINCI_ENV}")"

  if [[ -z "${DAVINCI_ENV}" ]]; then
    echo "DAVINCI_ENV not set, exiting"
    return 1
  fi

  # unset all the exported vars
  unset DAVINCI_ENV
  davinci-env::unset_at_path "${curr_env_dir}"
  davinci-env::unset_at_path "${git_env_dir}"
}

davinci-env::source_sh_files() {
  local path_="$1"

  for f in $(find "${path_}" -type f -name '*.sh'); do
    . "${f}"
  done

  for f in $(find "${path_}" -type f -name '*.sh.gpg'); do
    . <(gpg -d "${f}")
  done
}

davinci-env::local_git_env_path() {
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

davinci-env::print_env() {
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
    davinci-env::print_env
  fi

  # second, unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset

  # set the new env
  export DAVINCI_ENV="${new_env}"

  local global_env_dir="${DAVINCI_ENV_PATH}/${new_env}"
  local git_env_dir="$(davinci-env::local_git_env_path "${new_env}")"

  if ! [[ -d "${global_env_dir}" ]] && ! [[ -d "${git_env_dir}" ]]; then
    echo "no davinci-env called '${new_env}'"
    return 1
  else
    if [[ -d "${global_env_dir}" ]]; then
      davinci-env::source_sh_files "${global_env_dir}"
    fi

    if [[ -d "${git_env_dir}" ]]; then
      davinci-env::source_sh_files "${git_env_dir}"
    fi
  fi
}
