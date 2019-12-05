#!/bin/bash

# stolen from git itself
__davinci_git_ps1 ()
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

_ovpn_tb_ps1() {
  local vpns="$(davinci-ovpn-tb-ls | awk '{ gsub(/-\w+-\w+-[[:digit:]]+/, ""); printf "%s", NR==1?$0:","$0 }')"
  if [[ -n "${vpns}" ]]; then
    case "$(_lib_current_shell)" in
      bash)
        echo "${PROMPT_COLOR_LIGHT_RED}(v:${vpns})${PROMPT_COLOR_RESET}"
        ;;
      zsh)
        echo "%F{red}%S%B(v:${vpns})%b%s%f"
        ;;
    esac
  fi
}

_git_color_ps1() {
  if test $(git status 2> /dev/null | grep -c :) -eq 0; then
    echo "${PROMPT_COLOR_GREEN}$(__davinci_git_ps1)${PROMPT_COLOR_RESET}"
  else
    echo "${PROMPT_COLOR_RED}$(__davinci_git_ps1)${PROMPT_COLOR_RESET}"
  fi
}

_davinci_env_ps1() {
  local new_ps1
  local parens_color="${PROMPT_COLOR_LIGHT_GREEN}"
  local env_color="${PROMPT_COLOR_LIGHT_YELLOW}"
  local sensitive_env_color="${PROMPT_COLOR_RED_HL_BLACK}"
  local somewhat_sensitive_env_color="${PROMPT_COLOR_LIGHT_YELLOW}"
  local vpn_color="${PROMPT_COLOR_PURPLE}"
  local aws_color="${PROMPT_COLOR_YELLOW}"
  local do_color="${PROMPT_COLOR_BLUE}"
  local terraform_ws_color="${PROMPT_COLOR_RED_HL}"

  # empty prompt section if env isnt set
  if [[ -z "${DAVINCI_ENV}" ]] ; then
    if [[ "$(ps -ef | grep 'openvpn --config' | grep -v grep | wc -l)" != "0" ]]; then
      echo "${parens_color}(${vpn_color}v${parens_color})${PROMPT_COLOR_RESET}"
    else
      echo
    fi
    return 0
  fi

  if [[ "${DAVINCI_ENV}" == "prod" ]] ; then
    new_ps1="${sensitive_env_color}${DAVINCI_ENV_FULL}${PROMPT_COLOR_RESET}"
  elif [[ "${DAVINCI_ENV}" == "dev" ]] ; then
    new_ps1="${somewhat_sensitive_env_color}${DAVINCI_ENV_FULL}${PROMPT_COLOR_RESET}"
  else
    new_ps1="${env_color}${DAVINCI_ENV_FULL}"
  fi

  local tf_ws="$(\terraform workspace show)"

  #if [[ "${PWD}" == *terraform* ]] && [[ "${DAVINCI_ENV_FULL}" != "${tf_ws}" ]]; then
    #new_ps1="${new_ps1}${terraform_ws_color}!tf${PROMPT_COLOR_RESET}"
  #fi

  if davinci-ovpn ls | grep -q "${DAVINCI_ENV}" ; then
     new_ps1="${new_ps1}${vpn_color}v"
  fi

  echo "${parens_color}(${new_ps1}${parens_color})${PROMPT_COLOR_RESET}"
}
