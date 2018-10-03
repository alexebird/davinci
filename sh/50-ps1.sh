#!/bin/bash

# stolen from git itself
__davinci_git_ps1 ()
{
  #local g="$(\git rev-parse --git-dir 2>/dev/null)"
  local g=".git"
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
      b="$(\git symbolic-ref HEAD 2>/dev/null)"
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
      b="$(\git symbolic-ref HEAD 2>/dev/null)"
    else
      if [ -f "$g/BISECT_LOG" ]
      then
        r="|BISECTING"
      fi
      if ! b="$(\git symbolic-ref HEAD 2>/dev/null)"
      then
        if ! b="$(\git describe --exact-match HEAD 2>/dev/null)"
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


#_git_color_ps1() {
  #if test $(\git status --porcelain | wc -l) -eq 0 ; then
    #echo "${PROMPT_COLOR_GREEN}$(__davinci_git_ps1)${PROMPT_COLOR_RESET}"
  #else
    #echo "${PROMPT_COLOR_RED}$(__davinci_git_ps1)${PROMPT_COLOR_RESET}"
  #fi
#}

_davinci_env_ps1() {
  local new_ps1
  local parens_color="${PROMPT_COLOR_LIGHT_GREEN}"
  local env_color="${PROMPT_COLOR_LIGHT_YELLOW}"
  local sensitive_env_color="${PROMPT_COLOR_RED_HL_BLACK}"
  local somewhat_sensitive_env_color="${PROMPT_COLOR_LIGHT_YELLOW}"

  # empty prompt section if env isnt set
  #if [[ -z "${DAVINCI_ENV}" ]] ; then
    #echo
    #return 0
  #fi

  #if [[ "${DAVINCI_ENV}" == "prod" ]] ; then
    #new_ps1="${sensitive_env_color}${DAVINCI_ENV_FULL}${PROMPT_COLOR_RESET}"
  #elif [[ "${DAVINCI_ENV}" == "dev" ]] ; then
    #new_ps1="${somewhat_sensitive_env_color}${DAVINCI_ENV_FULL}${PROMPT_COLOR_RESET}"
  #else
    #new_ps1="${env_color}${DAVINCI_ENV_FULL}"
  #fi

  # empty prompt section if env isnt set
  local env="${AWS_ACCOUNT_NAME}"

  if [[ -z "${env}" ]] ; then
    echo
    return 0
  fi

  if [[ "${env}" == "production" ]] || [[ "${env}" == "corporate" ]]; then
    new_ps1="${sensitive_env_color}${env}${PROMPT_COLOR_RESET}"
  #elif [[ "${env}" == "dev" ]] ; then
    #new_ps1="${somewhat_sensitive_env_color}${env}${PROMPT_COLOR_RESET}"
  else
    new_ps1="${env_color}${env}"
  fi

  echo "${parens_color}(${new_ps1}${parens_color})${PROMPT_COLOR_RESET}"
}
