#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_string.sh"
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

function ez_trim_string() {
    local valid_keys=("left" "right" "both" "any")
    local valid_keys_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_keys[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_trim_string" -d "Trim input string")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--string" -d "The string to be trimmed")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--pattern" -d "Substring Pattern, default=${EZ_BASH_SPACE}")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--count" -d "Occurrence of the pattern, default is infinite")
    usage_string+=$(ez_build_usage -o "add" -a "-k|--key" -d "Valid Keys: [${valid_keys_string}], default = any")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local input_string=""
    local pattern="${EZ_BASH_SPACE}"
    local key="any"
    local count=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--string") shift; input_string=${1-} ;;
            "-p" | "--pattern") shift; pattern=${1-} ;;
            "-k" | "--key") shift; key=${1-} ;;
            "-c" | "--count") shift; count=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if ! ez_argument_check -n "-k|--key" -v "${key}" -c "${valid_keys[@]}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-s|--string" -v "${input_string}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-p|--pattern" -v "${pattern}" -o "${usage_string}"; then return 1; fi
    if [[ "${pattern}" ==  "${EZ_BASH_SPACE}" ]]; then pattern=" "; fi
    if [[ "${key}" == "any" ]]; then
        echo "${input_string}" | sed "s/${pattern}//g"
    elif [[ "${key}" == "left" ]]; then
        if [[ "${count}" == "" ]]; then
            echo "${input_string}" | sed "s/^\(${pattern}\)\{1,\}//"
        else
            echo "${input_string}" | sed "s/^\(${pattern}\)\{1,${count}\}//"
        fi
    elif [[ "${key}" == "right" ]]; then
        if [[ "${count}" == "" ]]; then
            echo "${input_string}" | sed "s/\(${pattern}\)\{1,\}$//"
        else
            echo "${input_string}" | sed "s/\(${pattern}\)\{1,${count}\}$//"
        fi
    fi
}

function ez_string_length() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_string_length" -d "Print Number of Characters")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--string" -d "The input string")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local input_string=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--string") shift; input_string=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    echo "${#input_string}"
}