#!/bin/bash

alias bs='git branch-search'
alias fco='git fast-checkout'
alias pm='git checkout master && git pull && git checkout - && git merge master'
alias git-track='git branch --set-upstream-to=origin/`bs` `bs`'

davinci-orphaned_local_branches() {
  local remotes=$(git branch -a | grep '  remotes' | sed -e's|  remotes/origin/||')
  for e in $(git branch | sed -e's/\(* \)\|\(  \)//') ; do
    echo "$remotes" | grep -q $e || echo "$e"
  done
}
