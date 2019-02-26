#!/usr/bin/env bash
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_get_os_type() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ "$(uname -s)" == "Linux" ]]; then
        echo "linux"
    else
        echo "unknow"
    fi
}

function ez_get_md5_cmd() {
    local os=$(ez_get_os_type)
    if [[ "${os}" == "macos" ]]; then
        if [[ $(ez_command_check -c "md5") == "${EZ_BASH_BOOL_FALSE}" ]]; then
            ez_print_log -l ERROR -m "\"md5\" not found!"
            ez_print_log -l INFO -m "Please run \"brew install md5\""
        else
            echo "md5 -q"
        fi
    elif [[ "${os}" == "linux" ]]; then
        if [[ $(ez_command_check -c "md5sum") == "${EZ_BASH_BOOL_FALSE}" ]]; then
            ez_print_log -l ERROR -m "\"md5sum\" not found!"
            ez_print_log -l INFO -m "Please run \"yum install md5sum\""
        else
            echo "md5sum"
        fi
    fi
}

function ez_get_file_descriptor_count() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_file_descriptor_count" -d "Find the count of file descriptor used by a process")
    usage_string+=$(ez_build_usage -o "add" -a "--pid" -d "Process ID")
    usage_string+=$(ez_build_usage -o "add" -a "--name" -d "Process Name, only works for linux")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local pid=""
    local name=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "--pid") shift; pid="${1-}" ;;
            "--name") shift; name="${1-}" ;;
            *)
                echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    local fd_count=0
    local os=$(ez_get_os_type)
    if [[ "$pid" != "" ]] && [[ "${name}" != "" ]]; then ez_print_log -l ERROR -m "Cannot use --pid and --name together"; return 1
    elif [[ "$pid" == "" ]] && [[ "${name}" == "" ]]; then ez_print_log -l ERROR -m "Must provide --pid or --name"; return 1
    elif [[ "${pid}" == "" ]]; then
        if [[ "${os}" == "linux" ]]; then
            for pid in $(pgrep -f "${name}"); do fd_count=$(echo "${fd_count} + $(ls -l /proc/${pid}/fd | wc -l | bc)" | bc); done
        elif [[ "${os}" == "macos" ]]; then
            ez_print_log -l ERROR -m "\"--name\" only works on linux"; return 1
        fi
    else
        if [[ "${os}" == "linux" ]]; then
            fd_count=$(ls -l /proc/${pid}/fd | wc -l | bc)
        elif [[ "${os}" == "macos" ]]; then
            fd_count=$(lsof -p ${pid} | wc -l | bc)
        fi
    fi    
    echo ${fd_count}
}

