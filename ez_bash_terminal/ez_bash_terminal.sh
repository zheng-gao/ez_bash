#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
[[ -z "${EZ_BASH_HOME}" ]] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1


###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

# Set prompt "[USER@HOST (TIME) PATH]$"
PS1='[\u@\h \[\e[1;34m\](\t) \[\e[1;31m\]\w\[\e[0m\]]\$ '

alias ll='ls -l'
alias ld='ls -ld'
alias la='ls -la'
alias ssh='ssh -K'

export LSCOLORS=GxFxCxDxBxegedabagaced
export CLICOLOR=1


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################


function ez_terminal_set_title() {
    ez_set_argument -s "-t" --long "--title" --type "String" --required --default "hostname" --info "Terminal Title" || return 1
    [[ ! -z "${@}" ]] && ez_ask_for_help "${@}" && ez_function_help && return
    local title; title="$(ez_get_argument --short "-t" --long "--title" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ "${title}" == "hostname" ]]; then title=$(hostname); fi
    echo -n -e "\033]0;${title}\007"
}