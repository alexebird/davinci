#!/bin/bash

_help_aws-env() {
  cat <<HERE
Usage: ${1:?must pass cmdname} ENV

This has autocompletion.

Sets AWS_* environment variables for use with awscli and other tooling.
HERE
}

davinci-aws-env() {
  echo "aws-env is deprecated as of May 25 2017"
  _davinci_help_helper "$@" && return 0
  local new_env="${1:-}"

  if [[ -z "${new_env}" ]]; then
    if [[ -n "${AWS_ENV}" ]]; then
      echo "${AWS_ENV}"
      return 0
    else
      return 1
    fi
  fi

  local env_file="${HOME}/.davinci-env/aws/${new_env}.sh"
  local curr_env_file="${HOME}/.davinci-env/aws/${AWS_ENV}.sh"

  if [[ -f "${env_file}" ]]; then
    export AWS_ENV="${new_env}"
    . "${env_file}"
  elif [[ "${new_env}" == "unset" ]]; then
    if [[ -n "${AWS_ENV}" ]]; then
      unset AWS_ENV
      for v in $(cat "${curr_env_file}" | grep -Po 'AWS_[A-Z_]+'); do
        unset "${v}"
      done
    fi
  else
    echo "no aws-env called '${new_env}'"
    return 1
  fi
}

if _lib_is_shell_bash; then
  complete -W'bird dev testing it og prod unset' davinci-aws-env
fi



_help_aws-make-creds-file() {
  cat <<HERE
Usage: ${1} ENV

Creates a ENV.sh file with creds from the latest ~/Downloads/credentials*.csv file, which can be downloaded when you make a new IAM user.
HERE
}

davinci-aws-make-creds-file() {
  _davinci_help_helper "${FUNCNAME[0]}" "$@" && return 0
  local env="${1:?must set creds}"
  local creds_file=$(find ~/Downloads/ -name 'credentials*.csv' -printf "%T+\t%p\n" | sort | tail -1 | cut -f2-)
  local contents="$(cat "${creds_file}" | tail -1)"

  local region="$(find "${DAVINCI_HOME}/infra-terraform/stacks/" -maxdepth 1 -exec basename {} \; | grep -vP 'stacks|skeleton' | grep "${env}")"
  region="${region/${env}-/}"

  cat <<HERE
# DO NOT COPY TO HOSTS OTHER THAN YOUR PERSONAL MACHINE!!!
# DO NOT CHECK IN TO GIT REPOS WITHOUT ENCRYPTING!!!
#
# iam user: $(echo "${contents}" | cut -d, -f1)
# console login url: $(echo "${contents}" | cut -d, -f5)
# console password: $(echo "${contents}" | cut -d, -f2)
export AWS_DEFAULT_REGION='${region}'
export AWS_REGION="\${AWS_DEFAULT_REGION}"
export AWS_ACCESS_KEY_ID='$(echo "${contents}" | cut -d, -f3)'
export AWS_SECRET_ACCESS_KEY='$(echo "${contents}" | cut -d, -f4)'
HERE
}
