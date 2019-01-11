#!/usr/bin/env bash
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_grep.sh"
if [[ "${0}" != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        echo "[EZ-BASH][ERROR] ${THIS_SCRIPT_NAME} is not runnable!"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"
        exit 1
    fi
fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if ! source "${EZ_BASH_HOME}/ez_bash_log/ez_bash_log.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_variables/ez_bash_variables.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_sanity_check/ez_bash_sanity_check.sh"; then exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_grep_ith_line() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_grep_ith_line" -d "Grep the i-th line, use after pipe")
    usage_string+=$(ez_build_usage -o "add" -a "-i|--ith-line" -d "The line number, default = 1")
    usage_string+=$(ez_build_usage -o "add" -a "-r|--reverse" -d "[Boolean] Grep the i-th line to the end")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local ith_line=1
    local reverse="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-i" | "--ith-line") shift; ith_line=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-r" | "--reverse") shift; reverse="${EZ_BASH_BOOL_TRUE}" ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_nonempty_check -n "-i|--ith-line" -v "${ith_line}" -o "${usage_string}"; then return 1; fi
    if [[ "${reverse}" == "${EZ_BASH_BOOL_FALSE}" ]]; then
        head -n "${ith_line}" | tail -n 1
    else
        tail -n "${ith_line}" | head -n 1
    fi
}
