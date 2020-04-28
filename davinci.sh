#!/usr/bin/env bash

# nice short abbreviation
de() {
  local POSITIONAL=()
  local PRINT='f'

  #set -x

  while [[ $# -gt 0 ]] ; do
    key="$1"

    case $key in
      -p|--print)
        PRINT='t'
        shift
        ;;
      -h|--help)
        cat <<HERE
usage: de [OPTIONS] ENV...

OPTIONS:
--print, -p - Don't eval files, just print contents.
--help,  -h
HERE
        return 0
        shift
        ;;
      #-s|--searchpath)
        #SEARCHPATH="$2"
        #shift # past argument
        #shift # past value
        #;;
      *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
  done

  set -- "${POSITIONAL[@]}"

  local UNITS="$@"

  if [[ "$#" == 0 ]]; then
    echo "must pass some envs"
    return 1
  fi

  if ! which davinci > /dev/null ; then
    echo "can't find davinci binary"
    return 1
  fi

  if [[ "${PRINT}" == 't' ]]; then
    davinci search ${UNITS}
  else
    eval "$(
      davinci search ${UNITS}
    )"
  fi

  #set +x
}
