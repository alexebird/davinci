#!/bin/bash

# davinci-env: all-encompassing virtual env for infrastructure

GPG='gpg2'

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

davincienv::unset_at_path() {
  local path_="$1"

  if ! [[ -d "${path_}" ]]; then
    #echo "davinci-env: unset: path doesn't exist '${path_}'"
    return 1
  fi

  for v in $(find "${path_}" -maxdepth 1 -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//' | sort); do
    unset "${v}"
  done

  for e in $(find "${path_}" -maxdepth 1 -type f -name "*.sh.gpg" | sort); do
    for v in $(${GPG} -d "${e}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
      unset "${v}"
    done
  done
}

davincienv::source_sh_files() {
  local path_="$1"

  if ! [[ -d "${path_}" ]]; then
    #echo "davinci-env: source: path doesn't exist '${path_}'"
    return 1
  fi

  for f in $(find "${path_}" -maxdepth 1 -type f -name '*.sh' | sort); do
    . "${f}"
  done

  for f in $(find "${path_}" -maxdepth 1 -type f -name '*.sh.gpg' | sort); do
    . <(${GPG} -d "${f}")
  done
}

davincienv::local_git_env_path() {
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

davincienv::print_env() {
  if [[ -n "${DAVINCI_ENV}" ]]; then
    if [[ -n "${DAVINCI_SUBENV}" ]]; then
      echo "${DAVINCI_ENV}-${DAVINCI_SUBENV}"
    else
      echo "${DAVINCI_ENV}"
    fi
    return 0
  else
    return 1
  fi
}

davinci-davinci-env-unset() {
  local global_precommon_dir="${DAVINCI_ENV_PATH}/precommon"
  local global_env_dir="${DAVINCI_ENV_PATH}/${DAVINCI_ENV}"
  local global_subenv_dir="${DAVINCI_ENV_PATH}/${DAVINCI_ENV}/${DAVINCI_SUBENV}"
  local global_postcommon_dir="${DAVINCI_ENV_PATH}/postcommon"

  local project_local_precommon_dir="$(davincienv::local_git_env_path 'precommon')"
  local project_local_env_dir="$(davincienv::local_git_env_path "${DAVINCI_ENV}")"
  local project_local_subenv_dir="$(davincienv::local_git_env_path "${DAVINCI_ENV}/${DAVINCI_SUBENV}")"
  local project_local_postcommon_dir="$(davincienv::local_git_env_path 'postcommon')"

  if [[ -z "${DAVINCI_ENV}" ]]; then
    #echo "DAVINCI_ENV not set, exiting"
    return 1
  fi

  # unset all the exported vars
  unset DAVINCI_ENV_FULL
  unset DAVINCI_SUBENV
  unset DAVINCI_ENV
  davincienv::unset_at_path "${global_postcommon_dir}"
  davincienv::unset_at_path "${global_subenv_dir}"
  davincienv::unset_at_path "${global_env_dir}"
  davincienv::unset_at_path "${global_precommon_dir}"

  davincienv::unset_at_path "${project_local_postcommon_dir}"
  davincienv::unset_at_path "${project_local_subenv_dir}"
  davincienv::unset_at_path "${project_local_env_dir}"
  davincienv::unset_at_path "${project_local_precommon_dir}"
}

davinci-davinci-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}" ; shift
  local new_subenv="${1:-}" ; shift

  # support passing a combined env and subenv
  if echo "${new_env}" | grep -qP '^([a-z-]+)-([0-9]+)$'; then
    new_subenv="$(echo "${new_env}" | sed -e's/^[a-z-]\+-//')"
    new_env="$(echo "${new_env}" | sed -e's/-[0-9]\+$//')"
  fi

  # maybe print the current env
  if [[ -z "${new_env}" ]]; then
    davincienv::print_env
    return $?
  fi

  # check if new_env exists
  local global_precommon_dir="${DAVINCI_ENV_PATH}/precommon"
  local global_env_dir="${DAVINCI_ENV_PATH}/${new_env}"
  local global_subenv_dir="${DAVINCI_ENV_PATH}/${new_env}/${new_subenv}"
  local global_postcommon_dir="${DAVINCI_ENV_PATH}/postcommon"

  local project_local_precommon_dir="$(davincienv::local_git_env_path 'precommon')"
  local project_local_env_dir="$(davincienv::local_git_env_path "${new_env}")"
  local project_local_subenv_dir="$(davincienv::local_git_env_path "${new_env}/${new_subenv}")"
  local project_local_postcommon_dir="$(davincienv::local_git_env_path 'postcommon')"

  if ! [[ -d "${global_env_dir}" ]] && ! [[ -d "${project_local_env_dir}" ]]; then
    echo "davinci-env: no env called '${new_env}'"
    return 1
  fi

  # dont care about checking the subenv, because the client may simply use DAVINCI_ENV_FULL if they want
  #if [[ -n "${new_subenv}" ]]; then
    #if ! [[ -d "${global_subenv_dir}" ]] && ! [[ -d "${project_local_subenv_dir}" ]]; then
      #echo "davinci-env: no subenv called '${new_env}-${new_subenv}'"
      #return 1
    #fi
  #fi

  # unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset

  # set the new env
  export DAVINCI_ENV="${new_env}"

  if [[ -n "${new_subenv}" ]]; then
    export DAVINCI_SUBENV="${new_subenv}"
    export DAVINCI_ENV_FULL="${new_env}-${new_subenv}"
  else
    export DAVINCI_ENV_FULL="${new_env}"
  fi

  # source the env dirs
  davincienv::source_sh_files "${global_precommon_dir}"
  davincienv::source_sh_files "${global_env_dir}"
  davincienv::source_sh_files "${global_subenv_dir}"
  davincienv::source_sh_files "${global_postcommon_dir}"

  davincienv::source_sh_files "${project_local_precommon_dir}"
  davincienv::source_sh_files "${project_local_env_dir}"
  davincienv::source_sh_files "${project_local_subenv_dir}"
  davincienv::source_sh_files "${project_local_postcommon_dir}"
}
