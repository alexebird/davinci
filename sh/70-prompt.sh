#!/bin/bash

_davinci_safety_ps1() {
  if [ ${ZSH_VERSION} ]; then
    [ "${ORIG_PS1}" ] || ORIG_PS1="${PS1}"
    PS1="${ORIG_PS1} $(_davinci_env_ps1)%# "
  elif [ ${BASH_VERSION} ]; then
    _PROMPT_COLOR="${DAVINCI_PROMPT_COLOR}"
    if [[ "${USER}" == "root" ]]; then
      _PROMPT_COLOR="${PROMPT_COLOR_LIGHT_RED}"
    fi
    #PS1="${_PROMPT_COLOR}${DAVINCI_PROMPT_PREFIX} $(__davinci_git_ps1)$(_davinci_env_ps1)${_PROMPT_COLOR}\$${PROMPT_COLOR_RESET} "
    PS1="${_PROMPT_COLOR}${DAVINCI_PROMPT_PREFIX} $(_git_color_ps1)$(_davinci_env_ps1)${_PROMPT_COLOR}\$${PROMPT_COLOR_RESET} "
  fi
}

_davinci_set_safety_prompt_command() {
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a ; _davinci_safety_ps1"
}
