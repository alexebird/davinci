#!/bin/bash

_lib_git_assert_in_repo() {
  git rev-parse --show-toplevel > /dev/null
}

_lib_git_top_level() {
  git rev-parse --show-toplevel
}

_lib_current_shell() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    echo zsh
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    echo bash
  else
    echo unsupported shell
    return 1
  fi
}

_lib_is_shell_bash() {
  [[ "$(_lib_current_shell)" == "bash" ]] || return 1
}

_lib_is_shell_zsh() {
  [[ "$(_lib_current_shell)" == "zsh" ]] || return 1
}

_lib_yes_no_prompt() {
  local prompt_text="$1"
  read -p "${prompt_text}(y/N) " -r < /dev/tty
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}
