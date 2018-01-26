#!/bin/bash

_davinci_safety_ps1() {
  if [ ${ZSH_VERSION} ]; then
    [ "${ORIG_PS1}" ] || ORIG_PS1="${PS1}"
    #PS1="${ORIG_PS1} $(_aws_env_ps1)$(_nomad_env_ps1)$(_vpn_ps1)%# "
    PS1="${ORIG_PS1} $(_davinci_env_ps1)%# "
  elif [ ${BASH_VERSION} ]; then
    #PS1="${PROMPT_COLOR_CYAN}\W$(_git_color_ps1)$(_aws_env_ps1)$(_nomad_env_ps1)$(_ovpn_native_ps1)${PROMPT_COLOR_CYAN}\$${PROMPT_COLOR_RESET} "
    PS1="${PROMPT_COLOR_CYAN}${DAVINCI_PROMPT_PREFIX} $(_git_color_ps1)$(_davinci_env_ps1)${PROMPT_COLOR_CYAN}\$${PROMPT_COLOR_RESET} "
  fi
}

_davinci_set_safety_prompt_command() {
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a ; _davinci_safety_ps1"
}
