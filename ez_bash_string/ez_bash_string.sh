#!/usr/bin/env bash

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
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
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
    elif [[ "${key}" == "both" ]]; then
        if [[ "${count}" == "" ]]; then
            echo "${input_string}" | sed "s/^\(${pattern}\)\{1,\}//" | sed "s/\(${pattern}\)\{1,\}$//"
        else
            echo "${input_string}" | sed "s/^\(${pattern}\)\{1,${count}\}//" | sed "s/\(${pattern}\)\{1,${count}\}$//"
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
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    echo "${#input_string}"
}

function ez_string_check() {
    local valid_keys=("contains" "starts" "ends")
    local valid_keys_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_keys[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_string_check" -d "Check if given string conforms the given pattern")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--string" -d "The input string")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--pattern" -d "The input pattern")
    usage_string+=$(ez_build_usage -o "add" -a "-k|--key" -d "Valid Keys: [${valid_keys_string}]")
    usage_string+=$(ez_build_usage -o "add" -a "--silent" -d "Hide the output")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local input_string=""
    local pattern=""
    local key=""
    local silent="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--string") shift; input_string=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--pattern") shift; pattern=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-k" | "--key") shift; key=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--silent") shift; silent="${EZ_BASH_BOOL_TRUE}" ;;
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_argument_check -n "-k|--key" -v "${key}" -c "${valid_keys[@]}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-s|--string" -v "${input_string}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-p|--pattern" -v "${pattern}" -o "${usage_string}"; then return 1; fi
    if [[ "${key}" == "contains" ]]; then
        if [[ "${input_string}" == *"${pattern}"* ]]; then
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
            return 1
        fi
    elif [[ "${key}" == "starts" ]]; then
        if [[ "${input_string}" =~ ^"${pattern}".* ]]; then
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
            return 1
        fi
    elif [[ "${key}" == "ends" ]]; then
        if [[ "${input_string}" =~ .*"${pattern}"$ ]]; then
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
            return 1
        fi
    fi
}
