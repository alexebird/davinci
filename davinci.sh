#!/usr/bin/env bash

## shellcheck source=lib/utils.sh
#source "$(dirname "$(dirname "$0")")/lib/utils.sh"

## shellcheck source=lib/commands/help.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/help.sh"
## shellcheck source=lib/commands/update.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/update.sh"
## shellcheck source=lib/commands/install.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/install.sh"
## shellcheck source=lib/commands/uninstall.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/uninstall.sh"
## shellcheck source=lib/commands/current.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/current.sh"
## shellcheck source=lib/commands/where.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/where.sh"
## shellcheck source=lib/commands/which.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/which.sh"
## shellcheck source=lib/commands/version_commands.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/version_commands.sh"
## shellcheck source=lib/commands/list.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/list.sh"
## shellcheck source=lib/commands/list-all.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/list-all.sh"
## shellcheck source=lib/commands/reshim.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/reshim.sh"
## shellcheck source=lib/commands/plugin-add.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-add.sh"
## shellcheck source=lib/commands/plugin-list.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-list.sh"
## shellcheck source=lib/commands/plugin-list-all.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-list-all.sh"
## shellcheck source=lib/commands/plugin-update.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-update.sh"
## shellcheck source=lib/commands/plugin-remove.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-remove.sh"

## shellcheck source=lib/commands/plugin-push.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-push.sh"
## shellcheck source=lib/commands/plugin-test.sh
#source "$(dirname "$(dirname "$0")")/lib/commands/plugin-test.sh"

# shellcheck disable=SC2124
callback_args="${@:2}"

# shellcheck disable=SC2086
case $1 in

"--version")
    asdf_version $callback_args;;

#"help")
    #help_command $callback_args;;

#"update")
    #update_command $callback_args;;

#"install")
    #install_command $callback_args;;

#"uninstall")
    #uninstall_command $callback_args;;

#"current")
    #current_command $callback_args;;

#"where")
    #where_command $callback_args;;

#"which")
    #which_command $callback_args;;

#"local")
    #local_command $callback_args;;

#"global")
    #global_command $callback_args;;

#"list")
    #list_command $callback_args;;

#"list-all")
    #list_all_command $callback_args;;

#"shim")
    #shim_command $callback_args;;

#"reshim")
    #reshim_command $callback_args;;

#"plugin-add")
    #plugin_add_command $callback_args;;

#"plugin-list")
    #plugin_list_command $callback_args;;

#"plugin-list-all")
    #plugin_list_all_command $callback_args;;

#"plugin-update")
    #plugin_update_command $callback_args;;

#"plugin-remove")
    #plugin_remove_command $callback_args;;

## Undocumented commands for development
#"plugin-push")
    #plugin_push_command $callback_args;;

#"plugin-test")
    #plugin_test_command $callback_args;;

*)
  help_command
  exit 1;;
esac
