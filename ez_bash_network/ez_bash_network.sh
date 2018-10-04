#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_network.sh"
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


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_url_encode() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_url_encode" -d "Encode string for transmitting over the Internet")
    usage_string+=$(ez_build_usage -o "add" -a "-u|--url" -d "URL String to be encoded")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local input_list=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-u" | "--url") shift
                while [[ ! -z "${1-}" ]]; do
                    input_list+=("${1-}"); shift
                done ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    local url_string="${input_list[@]}"
    for (( i = 0; i < ${#url_string}; i++ )); do
        local character=${url_string:i:1}
        case ${character} in
            [a-zA-Z0-9.~_-]) printf ${character} ;;
            *) printf '%%%02X' "'$character"
        esac
    done
    echo
}
