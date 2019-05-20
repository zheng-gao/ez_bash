#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_LOG_LOGO="EZ-BASH"
export EZ_BASH_TAB_SIZE="30"
export EZ_BASH_BOOL_TRUE="true"
export EZ_BASH_BOOL_FALSE="false"
export EZ_BASH_SPACE="SPACE"
export EZ_BASH_ALL="ALL"
export EZ_BASH_NONE="NONE"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_print_usage() {
    tabs "${EZ_BASH_TAB_SIZE}"
    (>&2 printf "${1}\n")
}

function ez_build_usage() {
    local usage_string="[Function Name]\t\"ez_build_usage\"\n[Function Info]\tEZ-BASH standard usage builder\n"
    usage_string+="-o|--operation\tValid operations are \"add\" and \"init\"\n"
    usage_string+="-a|--argument\tArgument Name\n"
    usage_string+="-d|--description\tArgument Description\n"
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return; fi
    local operation=""
    local argument=""
    local description="No Description"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-o" | "--operation") shift; operation=${1-} ;;
            "-a" | "--argument") shift; argument=${1-} ;;
            "-d" | "--description") shift; description=${1-} ;;
            *) ez_log_error "Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${operation}" == "init" ]]; then
        if [[ "${argument}" == "" ]]; then argument="${FUNCNAME[1]}"; fi
        echo "\n[Function Name]\t\"${argument}\"\n[Function Info]\t${description}\n"
    elif [[ "${operation}" == "add" ]]; then
        echo "${argument}\t${description}\n"
    else
        ez_log_error "Invalid operation \"${operation}\""
        ez_print_usage "${usage_string}"
    fi
}

function ez_source() {
    if [[ "${1}" == "" ]]; then ez_log_error "Empty file path"; return 1; fi
    local file_path="${1}"
    if [ ! -f "${file_path}" ]; then ez_log_error "Invalid file path \"${file_path}\""; return 2; fi
    if [ ! -r "${file_path}" ]; then ez_log_error "Unreadable file \"${file_path}\""; return 3; fi
    if ! source "${file_path}"; then ez_log_error "Failed to source \"${file_path}\""; return 4; fi
}

function ez_source_directory() {
    local usage_string=$(ez_build_usage -o "init" -d "Source Directory")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
    usage_string+=$(ez_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return; fi
    local path="."
    local exclude=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-p" | "--path") shift; path=${1-} ;;
            "-r" | "--exclude") shift; exclude=${1-} ;;
            *) ez_log_error "Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${path}" == "" ]]; then ez_log_error "Invalid value \"${path}\" for \"-p|--path\""; return 1; fi
    if [ ! -d "${path}" ]; then ez_log_error "\"${path}\" is not a directory"; return 2; fi
    if [ ! -r "${path}" ]; then ez_log_error "Cannot read directory \"${dir_path}\""; return 3; fi
    if [[ "${exclude}" == "" ]]; then
        for sh_file_path in $(find "${path}" -type f -name '*.sh'); do
            if ! ez_source "${sh_file_path}"; then return 4; fi
        done
    else
        for sh_file_path in $(find "${path}" -type f -name '*.sh' | grep -v "${exclude}"); do
            if ! ez_source "${sh_file_path}"; then return 4; fi
        done
    fi
}
