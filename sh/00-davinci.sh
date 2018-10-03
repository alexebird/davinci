#!/bin/bash

_davinci_help_helper() {
  local calling_func=''

  case "$(_lib_current_shell)" in
    zsh)
      calling_func="${funcstack[2]}"
      ;;
    bash)
      calling_func=$(2>&1 caller 0 | head -1 | cut -f2 -d' ')
      ;;
  esac

  local first_arg="${1:-}"
  local help_func="${calling_func/davinci-/_help_}"

  case "${first_arg}" in
    -h|--help|help)
      if type "${help_func}" > /dev/null; then
        echo
        ${help_func} "${calling_func}"
        echo
      else
        echo
        echo "no help for ${calling_func}"
        echo
      fi
      return 0
      ;;
    *)
    ;;
  esac
  return 1
}

_davinci_opt_use_safety_prompt() {
  echo "${DAVINCI_OPTS}" | grep -q 'prompt'
}
