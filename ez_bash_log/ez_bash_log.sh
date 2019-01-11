#!/usr/bin/env bash

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_DEFAULT_LOG_FILE="/var/tmp/ez_bash.log"

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_log.sh"
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
if ! source "${EZ_BASH_HOME}/ez_bash_variables/ez_bash_variables.sh"; then exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_print_usage() {
    tabs "${EZ_BASH_TAB_SIZE}"
    printf "${1}"
}

function ez_build_usage() {
    local usage_string="[Command Name]\t\"ez_build_usage\"\n[Description ]\tEZ-BASH standard usage builder\n"
    usage_string+="-o|--operation\tValid operations are \"add\" and \"init\"\n"
    usage_string+="-a|--argument\tArgument Name\n"
    usage_string+="-d|--description\tArgument Description\n"
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local operation=""
    local argument=""
    local description="No Description"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-o" | "--operation") shift; operation=${1-} ;;
            "-a" | "--argument") shift; argument=${1-} ;;
            "-d" | "--description") shift; description=${1-} ;;
            *)
                echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"${1}\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${operation}" == "init" ]]; then
        echo "[Command Name]\t\"${argument}\"\n[Description ]\t${description}\n"
    elif [[ "${operation}" == "add" ]]; then
        echo "${argument}\t${description}\n"
    else
        echo "[${EZ_BASH_LOG_LOGO}][ERROR] Invalid operation \"${operation}\""
        ez_print_usage "${usage_string}"
    fi
}

function ez_print_log() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_log" -d "Print log in \"EZ-BASH\" standard log format to console")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
    usage_string+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local logger="INFO"
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-l" | "--logger") shift; logger="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--logger" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *)
                echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZ_BASH_LOG_LOGO}][${logger}] ${message[*]}"
}

function ez_print_log_to_file() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_log_to_file" -d "Print log in \"EZ-BASH\" standard log format to file")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
    usage_string+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--file" -d "Log file path")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local logger="INFO"
    local log_file=${EZ_BASH_DEFAULT_LOG_FILE}
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-l" | "--logger") shift; logger="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-f" | "--file") shift; log_file="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--logger" ]]; then break; fi
                    if [[ "${1-}" == "-f" ]] || [[ "${1-}" == "--file" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *)
                echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${log_file}" == "" ]]; then log_file=${EZ_BASH_DEFAULT_LOG_FILE}; fi
    # Make sure the log_file exists and you have the write permission
    if [ ! -e "${log_file}" ]; then touch "${log_file}"; fi
    if [ ! -f "${log_file}" ] || [ ! -w "${log_file}" ]; then
        ez_print_log -l "ERROR" -m "Log File \"${log_file}\" not exist or not writable"; return 1
    fi
    ez_print_log -l "${logger}" -m "${message[*]}" >> "${log_file}"
}

function ez_repeat_string() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_repeat_string" -d "Copy and concatenate the substring several times")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--substring" -d "Substring to be repeated, default \"=\"")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--count" -d "The count of the substrings, default \"80\"")
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local count=80
    local substring="="
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--substring") shift; substring=${1-} ;;
            "-c" | "--count") shift; count=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"${1}\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${count}" == "" ]] || [[ "${count}" < 0 ]]; then ez_print_log -l ERROR -m "Invalid Count \"${count}\""; return 1; fi
    local line=""
    for ((index=0; $index < ${count}; ++index)); do line+="${substring}"; done
    echo "$line"
}

function ez_print_banner() {
    local all_argument_names=("-s" "--substring" "-c" "--count" "-m" "--message" "-p" "--prefix")
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_banner" -d "Print \"EZ-BASH\" standard banner")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--substring" -d "The substring in the spliter, default is \"=\"")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--count" -d "The count of the substrings, default is \"80\"")
    usage_string+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print in the banner")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--prefix" -d "Print EZ-BASH log prefix")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local count=80
    local substring="="
    local prefix="${EZ_BASH_BOOL_FALSE}"
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--substring") shift; substring="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--count") shift; count="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--prefix") prefix="${EZ_BASH_BOOL_TRUE}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1}" ==  "-s" ]] || [[ "${1}" ==  "--substring" ]]; then break; fi
                    if [[ "${1}" ==  "-c" ]] || [[ "${1}" ==  "--count" ]]; then break; fi
                    if [[ "${1}" ==  "-m" ]] || [[ "${1}" ==  "--message" ]]; then break; fi
                    if [[ "${1}" ==  "-p" ]] || [[ "${1}" ==  "--prefix" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    local spliter=$(ez_repeat_string --substring "${substring}" --count ${count})
    if [[ "${prefix}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l INFO -m "${spliter}"
        ez_print_log -l INFO -m "${message[@]}"
        ez_print_log -l INFO -m "${spliter}"
    else
        echo "${spliter}"
        echo "${message[@]}"
        echo "${spliter}"
    fi
}
