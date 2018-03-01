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
    return 0
  fi

  for v in $(find "${path_}" -maxdepth 1 -type f -name "*.sh" | xargs grep -h '^export' | sed -e's/^export //' -e's/=.\+$//' | sort); do
    unset "${v}"
  done

  for e in $(find "${path_}" -maxdepth 1 -type f -name "*.sh.gpg" | sort); do
    for v in $(${GPG} --batch=yes --quiet -d "${e}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'); do
      unset "${v}"
    done
  done
}

davincienv::print_vars() {
  local path_="$1"
  local contents=''

  echo "${path_}"

  if echo "${path_}" | grep -q -E ".+\.sh$"; then
    contents="$(cat "${f}")"
    echo "${contents}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'
  elif echo "${path_}" | grep -q -E ".+\.sh\.gpg$"; then
    contents="$(${GPG} --batch=yes --quiet -d "${f}")"
    echo "${contents}" | grep -h '^export' | sed -e's/^export //' -e's/=.\+$//'
  fi
}

davincienv::source_sh_files() {

  local path_="$1"

  if ! [[ -d "${path_}" ]]; then
    return 0
  fi

  for f in $(find "${path_}" -maxdepth 1 -type f -name '*.sh' | sort); do
    davincienv::print_vars "${f}"
    . "${f}"
  done

  for f in $(find "${path_}" -maxdepth 1 -type f -name '*.sh.gpg' | sort); do
    davincienv::print_vars "${f}"
    . <(${GPG} --batch=yes --quiet -d "${f}")
  done
}

davincienv::local_git_env_path() {
  local current_git_root
  local project_local_env_dir

  if ! _lib_git_assert_in_repo; then
    return 1
  fi

  current_git_root="$(_lib_git_top_level)"
  project_local_env_dir="${current_git_root}/davinci/env"

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


davincienv::check_for_env() {
  local env="${1:?must pass env}" ; shift
  local paths="${1:?must pass paths}" ; shift

  for _path in $(echo ${paths} | sed -e 's/:/\n/g')
  do
    if [[ -d "${_path}/${env}" ]]; then
      return 0
    fi
  done

  echo "davinci-env: no env called '${new_env}' found at:"
  echo
  for _path in $(echo ${paths} | sed -e 's/:/\n/g')
  do
    echo "${_path}/${env}"
  done
  return 1
}

davincienv::set_env() {
  local new_env="${1:?must pass new_env}" ; shift
  local new_subenv="${1:-}" ; shift

  export DAVINCI_ENV="${new_env}"

  if [[ -n "${new_subenv}" ]]; then
    export DAVINCI_SUBENV="${new_subenv}"
    export DAVINCI_ENV_FULL="${new_env}-${new_subenv}"
  else
    export DAVINCI_ENV_FULL="${new_env}"
  fi
}

davincienv::source_auto() {
  local de_path="${DAVINCI_ENV_PATH}"

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g')
  do
    davincienv::source_sh_files "${_path}/auto"
  done
}

davinci-davinci-env-unset() {
  if [[ -z "${DAVINCI_ENV}" ]]; then
    # presume already unset, that's fine.
    return 0
  fi

  local de_path="${DAVINCI_ENV_PATH}:$(davincienv::local_git_env_path)"

  # use tac to reverse the de_path so that it is unset in the reverse order that it is set.
  for _path in $(echo ${de_path} | sed -e 's/:/\n/g' | tac)
  do
    davincienv::unset_at_path "${_path}/postcommon"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g' | tac)
  do
    davincienv::unset_at_path "${_path}/${DAVINCI_ENV}/${DAVINCI_SUBENV}"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g' | tac)
  do
    davincienv::unset_at_path "${_path}/${DAVINCI_ENV}"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g' | tac)
  do
    davincienv::unset_at_path "${_path}/precommon"
  done

  # unset all the exported vars
  unset DAVINCI_ENV_FULL
  unset DAVINCI_SUBENV
  unset DAVINCI_ENV
}

davinci-davinci-env() {
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}" ; shift

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
  if ! davincienv::check_for_env "${new_env}" "${DAVINCI_ENV_PATH}:${project_local_env_dir}" ; then
    return 1
  fi

  # unset the previous env so that we don't have vars leftover
  davinci-davinci-env-unset
  davincienv::set_env "${new_env}" "${new_subenv}"

  # source the env dirs
  local de_path="${DAVINCI_ENV_PATH}:$(davincienv::local_git_env_path)"

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g')
  do
    davincienv::source_sh_files "${_path}/precommon"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g')
  do
    davincienv::source_sh_files "${_path}/${new_env}"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g')
  do
    davincienv::source_sh_files "${_path}/${new_env}/${new_subenv}"
  done

  for _path in $(echo ${de_path} | sed -e 's/:/\n/g')
  do
    davincienv::source_sh_files "${_path}/postcommon"
  done
}
