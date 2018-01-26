#!/bin/bash
#set -x

GPG='gpg2'

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
  for path_ in $(_davinci_path_components); do
    if [[ -d "${path_}/sh" ]]; then
      for f in $(find "${path_}/sh" -type f -name '*.sh' | sort); do
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

    for f in $(find ${DAVINCI_ENV_PATH}/auto/ -type f -name '*.sh.gpg' | sort); do
      . <(${GPG} -d "${f}")
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

[ -z "${DAVINCI_PROMPT_PREFIX}" ] && export DAVINCI_PROMPT_PREFIX="\W"

[ -z "${DAVINCI_OPTS}" ] && export DAVINCI_OPTS=''

# gpgp
[ -z "${GPGP_PATH}" ]                 && export GPGP_PATH="$(_davinci_path_first_component)"
[ -z "${GPGP_EMAIL_DOMAINS}" ]        && export GPGP_EMAIL_DOMAINS=''
[ -z "${GPGP_PUB_KEY_ID_BLACKLIST}" ] && export GPGP_PUB_KEY_ID_BLACKLIST=''
[ -z "${GPGP_SECRETS_PATH}" ]         && export GPGP_SECRETS_PATH="${DAVINCI_HOME}/secrets"

# /end config env vars
# ====================

export PATH="${DAVINCI_CLONE}/bin:${PATH}"

for path_ in $(_davinci_path_components); do
  if [[ -d "${path_}/bin" ]]; then
      export PATH="${path_}/bin:${PATH}"
  fi
done

export MANPATH="${DAVINCI_CLONE}/man:${MANPATH}"

davinci-toolme

if _davinci_opt_use_safety_prompt; then
  [ ${ZSH_VERSION:-} ] && precmd() { _davinci_safety_ps1; }
  [ ${BASH_VERSION:-} ] && _davinci_set_safety_prompt_command
fi
