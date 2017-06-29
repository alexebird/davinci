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

  for v in $(find "${path_}" -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//' | sort); do
    unset "${v}"
  done

  for e in $(find "${path_}" -type f -name "*.sh.gpg" | sort); do
    for v in $(gpg -d "${e}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
      unset "${v}"
    done
  done
}

davinci-davinci-env-unset() {
  local global_common_dir="${DAVINCI_ENV_PATH}/common"
  local global_env_dir="${DAVINCI_ENV_PATH}/${DAVINCI_ENV}"
  local project_local_common_dir="$(davinci-env::local_git_env_path 'common')"
  local project_local_env_dir="$(davinci-env::local_git_env_path "${DAVINCI_ENV}")"

  if [[ -z "${DAVINCI_ENV}" ]]; then
    #echo "DAVINCI_ENV not set, exiting"
    return 1
  fi

  # unset all the exported vars
  unset DAVINCI_ENV
  davinci-env::unset_at_path "${global_env_dir}"
  davinci-env::unset_at_path "${global_common_dir}"
  davinci-env::unset_at_path "${project_local_env_dir}"
  davinci-env::unset_at_path "${project_local_common_dir}"
}

davinci-env::source_sh_files() {
  local path_="$1"

  for f in $(find "${path_}" -type f -name '*.sh' | sort); do
    . "${f}"
  done

  for f in $(find "${path_}" -type f -name '*.sh.gpg' | sort); do
    . <(gpg -d "${f}")
  done
}

davinci-env::local_git_env_path() {
  local env="$1"
  local current_git_root
  local project_local_env_dir

  if ! _lib_git_assert_in_repo; then
    return 1
  fi

  current_git_root="$(_lib_git_top_level)"
  project_local_env_dir="${current_git_root}/davinci/env/${env}"

  if [[ -d "${project_local_env_dir}" ]]; then
    echo "${project_local_env_dir}"
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
  local new_env="${1:-}" ; shift

  # maybe print the current env
  if [[ -z "${new_env}" ]]; then
    davinci-env::print_env
    return $?
  fi

  # check if new_env exists
  local global_common_dir="${DAVINCI_ENV_PATH}/common"
  local global_env_dir="${DAVINCI_ENV_PATH}/${new_env}"
  local project_local_common_dir="$(davinci-env::local_git_env_path 'common')"
  local project_local_env_dir="$(davinci-env::local_git_env_path "${new_env}")"

  if ! [[ -d "${global_env_dir}" ]] && ! [[ -d "${project_local_env_dir}" ]]; then
    echo "no davinci-env called '${new_env}'"
    return 1
  fi

  # unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset

  # set the new env
  export DAVINCI_ENV="${new_env}"

  if [[ -d "${global_common_dir}" ]]; then
    davinci-env::source_sh_files "${global_common_dir}"
  fi

  if [[ -d "${global_env_dir}" ]]; then
    davinci-env::source_sh_files "${global_env_dir}"
  fi

  if [[ -d "${project_local_common_dir}" ]]; then
    davinci-env::source_sh_files "${project_local_common_dir}"
  fi

  if [[ -d "${project_local_env_dir}" ]]; then
    davinci-env::source_sh_files "${project_local_env_dir}"
  fi
}
