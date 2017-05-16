#!/bin/bash
#set -x

# config env vars
export DAVINCI_PATH="${HOME}/davinci"
export DAVINCI_PATH_USER="${HOME}/.davinci"
export DAVINCI_ENV_PATH="${HOME}/.davinci-env"

# gpgp
export DAVINCI_GPGP_PATH="${DAVINCI_PATH_USER}/gpg"
export DAVINCI_GPGP_EMAIL_DOMAINS='foobar.com'
export DAVINCI_SECRETS_PATH="${DAVINCI_HOME}/secrets"

# /end config env vars

export PATH="${DAVINCI_PATH}/bin:${PATH}"
export PATH="${DAVINCI_PATH}/go/bin:${PATH}"

if [[ -d "${HOME}/.davinci/bin" ]]; then
  export PATH="${HOME}/.davinci/bin:${PATH}"
fi

export MANPATH="${DAVINCI_PATH}/man:${MANPATH}"
export GOPATH="${DAVINCI_PATH}/go"

_davinci_source_bash() {
  for f in $(find ${DAVINCI_PATH}/sh/ -type f -name '*.sh' | sort); do
    . "${f}"
  done
}

_davinci_source_user_dot_davinci() {
  for f in $(find ${DAVINCI_PATH_USER}/sh/ -type f -name '*.sh' | sort); do
    . "${f}"
  done
}

_davinci_source_davinci_env_auto() {
  if [[ -d "${DAVINCI_ENV_PATH}" ]] && [[ -d "${DAVINCI_ENV_PATH}/auto/" ]]; then
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

davinci-toolme

if _davinci_opt_use_safety_prompt; then
  [ ${ZSH_VERSION:-} ] && precmd() { _davinci_safety_ps1; }
  [ ${BASH_VERSION:-} ] && _davinci_set_safety_prompt_command
fi
