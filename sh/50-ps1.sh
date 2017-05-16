#!/bin/bash

# stolen from git itself
__git_ps1 ()
{
  local g="$(git rev-parse --git-dir 2>/dev/null)"
  if [ -n "$g" ]; then
    local r
    local b
    if [ -d "$g/rebase-apply" ]
    then
      if test -f "$g/rebase-apply/rebasing"
      then
        r="|REBASE"
      elif test -f "$g/rebase-apply/applying"
      then
        r="|AM"
      else
        r="|AM/REBASE"
      fi
      b="$(git symbolic-ref HEAD 2>/dev/null)"
    elif [ -f "$g/rebase-merge/interactive" ]
    then
      r="|REBASE-i"
      b="$(cat "$g/rebase-merge/head-name")"
    elif [ -d "$g/rebase-merge" ]
    then
      r="|REBASE-m"
      b="$(cat "$g/rebase-merge/head-name")"
    elif [ -f "$g/MERGE_HEAD" ]
    then
      r="|MERGING"
      b="$(git symbolic-ref HEAD 2>/dev/null)"
    else
      if [ -f "$g/BISECT_LOG" ]
      then
        r="|BISECTING"
      fi
      if ! b="$(git symbolic-ref HEAD 2>/dev/null)"
      then
        if ! b="$(git describe --exact-match HEAD 2>/dev/null)"
        then
          b="$(cut -c1-7 "$g/HEAD")..."
        fi
      fi
    fi

    if [ -n "$1" ]; then
      printf "$1" "${b##refs/heads/}$r"
    else
      printf "(%s)" "${b##refs/heads/}$r"
    fi
  fi
}

_aws_env_ps1() {
  if [[ -n "${AWS_ENV}" ]] ; then
    if [[ "${AWS_ENV}" == "prod" ]] ; then
      case "$(_lib_current_shell)" in
        bash)
          echo "${COLOR_YELLOW}(a:${COLOR_YELLOW}${AWS_ENV}${COLOR_RED}!${COLOR_YELLOW})${COLOR_RESET}"
          ;;
        zsh)
          echo "%{%F{yellow}%}(a:${AWS_ENV}%{%F{red}%}!%{%F{yellow}%})%{%f%}"
          ;;
      esac
    else
      case "$(_lib_current_shell)" in
        bash)
          echo "${COLOR_YELLOW}(a:${AWS_ENV})${COLOR_RESET}"
          ;;
        zsh)
          echo "%{%F{yellow}%}(a:${AWS_ENV})%{%f%}"
          ;;
      esac
    fi
  fi
}

_nomad_env_ps1() {
  if [[ -n "${NOMAD_ENV}" ]] ; then
    local pids="$(_nomad_tunnel_pids)"
    if [[ "${NOMAD_ENV}" == "prod" ]] ; then
      if [[ -n "${pids}" ]]; then
        case "$(_lib_current_shell)" in
          bash)
            echo "${COLOR_BLUE}(n:${NOMAD_ENV}${COLOR_RED}!${COLOR_BLUE})${COLOR_RESET}"
            ;;
          zsh)
            echo "%F{blue}(n:${NOMAD_ENV}%F{red}!%F{blue})%f"
            ;;
        esac
      else
        case "$(_lib_current_shell)" in
          bash)
            echo "${COLOR_BLUE}(n:${COLOR_RED}${NOMAD_ENV}${COLOR_RED}!${COLOR_BLUE})${COLOR_RESET}"
            ;;
          zsh)
            echo "%F{blue}(n:%F{red}${NOMAD_ENV}!%F{blue})%f"
            ;;
        esac
      fi
    else
      if [[ -n "${pids}" ]]; then
        case "$(_lib_current_shell)" in
          bash)
            echo "${COLOR_BLUE}(n:${NOMAD_ENV})${COLOR_RESET}"
            ;;
          zsh)
            echo "%F{blue}(n:${NOMAD_ENV}%F{blue})%f"
            ;;
        esac
      else
        case "$(_lib_current_shell)" in
          bash)
            echo "${COLOR_BLUE}(n:${COLOR_RED}${NOMAD_ENV}${COLOR_BLUE})${COLOR_RESET}"
            ;;
          zsh)
            echo "%F{blue}(n:%F{red}${NOMAD_ENV}%F{blue})%f"
            ;;
        esac
      fi
    fi
  fi
}

_ovpn_tb_ps1() {
  local vpns="$(davinci-ovpn-tb-ls | awk '{ gsub(/-\w+-\w+-[[:digit:]]+/, ""); printf "%s", NR==1?$0:","$0 }')"
  if [[ -n "${vpns}" ]]; then
    case "$(_lib_current_shell)" in
      bash)
        echo "${COLOR_LIGHT_RED}(v:${vpns})${COLOR_RESET}"
        ;;
      zsh)
        echo "%F{red}%S%B(v:${vpns})%b%s%f"
        ;;
    esac
  fi
}

_ovpn_native_ps1() {
  local vpns="$(davinci-ovpn-native-ls | awk '{ printf "%s", NR==1?$0:","$0 }')"

  if [[ -n "${vpns}" ]]; then
    case "$(_lib_current_shell)" in
      bash)
        echo "${COLOR_LIGHT_RED}(v:${vpns})${COLOR_RESET}"
        ;;
      zsh)
        echo "%F{red}%S%B(v:${vpns})%b%s%f"
        ;;
    esac
  fi
}

_git_color_ps1() {
  if test $(git status 2> /dev/null | grep -c :) -eq 0; then
    echo "${COLOR_GREEN}$(__git_ps1)${COLOR_RESET}"
  else
    echo "${COLOR_RED}$(__git_ps1)${COLOR_RESET}"
  fi
}
