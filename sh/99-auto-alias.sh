#!/bin/bash

_auto_alias_bash_functions() {
  for cmd in $(declare -F | grep davinci- | sed -e's/declare -f davinci-//'); do
    # add non-'davinci-'-prefixed alias for functions which start with "davinci-"
    eval "alias ${cmd}='davinci-${cmd}'"

    # add non-davinci autocompletion
    local cmd_complete="$(complete -p | grep davinci-${cmd})"
    if [[ -n "${cmd_complete}" ]]; then
      eval "$(echo "${cmd_complete}" | awk 'NF{NF--};1') ${cmd}"
    fi
  done
}

_auto_alias_zsh_functions() {
  for cmd in $(print -l ${(ok)functions} | grep davinci- | sed -e's/davinci-//'); do
    # add non-'davinci-'-prefixed alias for functions which start with "davinci-"
    eval "alias ${cmd}='davinci-${cmd}'"
  done
}

_auto_alias_bin() {
  for f in $(find ${DAVINCI_CLONE}/bin/ -type f -o -type l); do
    eval "alias davinci-$(basename ${f})='$(basename ${f})'"
  done
}

_auto_alias() {
  if _lib_is_shell_bash; then
    _auto_alias_bash_functions
  elif _lib_is_shell_zsh; then
    _auto_alias_zsh_functions
  fi
  _auto_alias_bin
}

_auto_alias
