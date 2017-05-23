#!/bin/bash
#set -x

_davinci_path_first_component() {
  _davinci_path_components | head -1
}

_davinci_path_components() {
  echo "${DAVINCI_PATH}" | sed -e's/:/\n/'
}

_davinci_source_bash() {
  for f in $(find ${DAVINCI_CLONE}/sh/ -type f -name '*.sh' | sort); do
    . "${f}"
  done
}

_davinci_source_user_dot_davinci() {
  for path in $(_davinci_path_components); do
    if [[ -d "${path}/sh" ]]; then
      for f in $(find "${path}/sh" -type f -name '*.sh' | sort); do
        . "${f}"
      done
    fi
  done
}

_davinci_source_davinci_env_auto() {
  if [[ -d "${DAVINCI_ENV_PATH}" ]] && [[ -d "${DAVINCI_ENV_PATH}/auto" ]]; then
    for f in $(find ${DAVINCI_ENV_PATH}/auto/ -type f -name '*.sh' | sort); do
      . "${f}"
    done
  fi
}

davinci-toolme() {
  _davinci_source_bash
  _davinci_source_user_dot_davinci
  _davinci_source_davinci_env_auto
}

# config env vars
# ===============
#

# general paths
[ -z "${DAVINCI_CLONE}" ]    && export DAVINCI_CLONE="${HOME}/davinci"
[ -z "${DAVINCI_HOME}" ]     && { echo "must set DAVINCI_HOME"; return 1 ; }
[ -z "${DAVINCI_PATH}" ]     && export DAVINCI_PATH="${HOME}/.davinci"
[ -z "${DAVINCI_ENV_PATH}" ] && export DAVINCI_ENV_PATH="${HOME}/.davinci-env"

[ -z "${DAVINCI_OPTS}" ] && export DAVINCI_OPTS=''

# gpgp
[ -z "${DAVINCI_GPGP_PATH}" ]          && export DAVINCI_GPGP_PATH="$(_davinci_path_first_component)"
[ -z "${DAVINCI_GPGP_EMAIL_DOMAINS}" ] && { echo "must set DAVINCI_GPGP_EMAIL_DOMAINS"; return 1 ; }
[ -z "${DAVINCI_GPGP_SECRETS_PATH}" ]  && export DAVINCI_GPGP_SECRETS_PATH="${DAVINCI_HOME}/secrets"

# /end config env vars
# ====================


export PATH="${DAVINCI_CLONE}/bin:${PATH}"
export PATH="${DAVINCI_CLONE}/go/bin:${PATH}"

for path in $(_davinci_path_components); do
  if [[ -d "${path}/bin" ]]; then
    export PATH="${path}/bin:${PATH}"
  fi
done

export MANPATH="${DAVINCI_CLONE}/man:${MANPATH}"
export GOPATH="${DAVINCI_CLONE}/go"


davinci-toolme

if _davinci_opt_use_safety_prompt; then
  [ ${ZSH_VERSION:-} ] && precmd() { _davinci_safety_ps1; }
  [ ${BASH_VERSION:-} ] && _davinci_set_safety_prompt_command
fi
