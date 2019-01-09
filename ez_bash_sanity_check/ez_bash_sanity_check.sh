#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_sanity_check.sh"
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

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_command_check() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_command_check" -d "Check if the given command exist or not")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--command" -d "Command Name")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--silent" -d "Hide boolean output")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local command=""
    local silent="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-c" | "--command") shift; command="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--silent") shift; silent="${EZ_BASH_BOOL_TRUE}" ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! which "${command}" &> /dev/null; then
        if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
        return 1
    fi
    if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
}

function ez_nonempty_check() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_nonempty_check" -d "Check if the variable is non-empty")
    usage_string+=$(ez_build_usage -o "add" -a "-n|--name" -d "Argument Name")
    usage_string+=$(ez_build_usage -o "add" -a "-v|--value" -d "Argument Value")
    usage_string+=$(ez_build_usage -o "add" -a "-o|--output" -d "Output String")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--silent" -d "Hide output")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--print" -d "Print boolean result")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local name=""
    local value=()
    local output=""
    local silent="${EZ_BASH_BOOL_FALSE}"
    local print="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]]; then shift
            if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then continue; fi
            if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then continue; fi
            if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then continue; fi
            name="${1-}"; shift
        elif [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]]; then shift
            if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then continue; fi
            if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then continue; fi
            if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then continue; fi
            output="${1-}"; shift
        elif [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then shift; silent="${EZ_BASH_BOOL_TRUE}"
        elif [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then shift; print="${EZ_BASH_BOOL_TRUE}"
        elif [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then shift
            if [[ "${1-}" == "" ]]; then shift
            else
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then break; fi
                    if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then break; fi
                    if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then break; fi
                    value+=("${1-}"); shift
                done
            fi
        else
            ez_print_log -l ERROR -m "Unknown argument \"${1}\""
            ez_print_usage "${usage_string}"; return 1
        fi
    done
    if [[ "${value[@]}" == "" ]]; then
        if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then
            ez_print_log -l ERROR -m "\"${name}\" is empty!"
            ez_print_usage "${output}"
        fi
        if [[ "${print}" == "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
        return 1
    fi
    if [[ "${print}" == "${EZ_BASH_BOOL_TRUE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
}

function ez_variable_check() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_variable_check" -d "Check if the variable is set or not")
    usage_string+=$(ez_build_usage -o "add" -a "-n|--name" -d "Variable Name")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--print" -d "Print Variable Value")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local variable_name=""
    local print_value="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-n" | "--name") shift; variable_name="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--print") shift; print_value="${EZ_BASH_BOOL_TRUE}" ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_nonempty_check -n "-n|--name" -v "${variable_name}" -o "${usage_string}"; then return 1; fi
    if [ -v "${variable_name}" ]; then
        if [[ "${print_value}" == "${EZ_BASH_BOOL_TRUE}" ]]; then echo "Variable \"${variable_name}\" is set to \"${!variable_name}\""; fi
        return 0
    else
        if [[ "${print_value}" == "${EZ_BASH_BOOL_TRUE}" ]]; then echo "Variable \"${variable_name}\" is unset"; fi
        return 1
    fi
}

function ez_argument_check() {
    local all_argument_names=("-n" "--name" "-v" "--value" "-o" "--output" "-c" "--choices")
    local usage_string=$(ez_build_usage -o "init" -a "ez_argument_check" -d "Check if the argument option is valid")
    usage_string+=$(ez_build_usage -o "add" -a "-n|--name" -d "Argument Name")
    usage_string+=$(ez_build_usage -o "add" -a "-v|--value" -d "Argument Value")
    usage_string+=$(ez_build_usage -o "add" -a "-o|--output" -d "Output String")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--choices" -d "Valid Choices")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local name=""
    local value=""
    local output=""
    local choices=()
    while [[ ! -z "${1-}" ]]; do
        if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then name="${1-}"; shift; fi
        elif [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then value="${1-}"; shift; fi
        elif [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then output="${1-}"; shift; fi
        elif [[ "${1}" == "-c" ]] || [[ "${1}" == "--choices" ]]; then shift
            if [[ "${1-}" == "" ]]; then shift
            else
                while [[ ! -z "${1-}" ]]; do
                    if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") == "${EZ_BASH_BOOL_TRUE}" ]]; then break; fi
                    choices+=("${1-}"); shift
                done
            fi
        else
            ez_print_log -l ERROR -m "Unknown argument \"$1\""
            ez_print_usage "${usage_string}"; return 1
        fi
    done
    if [[ $(ez_check_item_in_array -i "${value}" -a "${choices[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l ERROR -m "Invalid value \"${value}\" for \"${name}\""
        ez_print_usage "${output}"
        return 1
    fi
}

function ez_path_check() {
    local valid_keys=("Nonempty-File" "Directory")
    local valid_keys_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_keys[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_file_system_check" -d "Check if the given path is a valid file or directory")
    usage_string+=$(ez_build_usage -o "add" -a "-k|--key" -d "Valid Keys: [${valid_keys_string}], default = \"nonempty-file\"")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--path" -d "Given Path")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--silent" -d "[Optional][Bool] Does not print error log")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local key=""
    local path=""
    local silent="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-k" | "--key") shift; key=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--path") shift; path=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--silent") shift; silent="${EZ_BASH_BOOL_TRUE}" ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_nonempty_check -n "-p|--path" -v "${path}" -o "${usage_string}"; then return 1; fi
    if ! ez_argument_check -n "-k|--key" -v "${key}" -c "${valid_keys[@]}" -o "${usage_string}"; then return 1; fi
    if [[ ! -e "${path}" ]]; then ez_print_log -l "ERROR" -m "${path} does not exist"; return 1; fi
    if [[ "${key}" == "Nonempty-File" ]]; then
        if [[ ! -f "${path}" ]]; then
            if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then ez_print_log -l "ERROR" -m "${path} is not a file"; fi
            return 1
        elif [[ ! -s "${path}" ]]; then
            if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then ez_print_log -l "ERROR" -m "${path} is empty"; fi
            return 1
        fi
    elif [[ "${key}" == "Directory" ]]; then
        if [[ ! -d "${path}" ]]; then
            if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then ez_print_log -l "ERROR" -m "${path} is not a directory"; fi
            return 1
        fi
    fi
    return 0
}


function ez_sanity_check() {
    local command_list=("date" "uname" "printf")
    for command in "${command_list[@]}"; do
        if [[ $(ez_command_check -c "${command}") == "${EZ_BASH_BOOL_FALSE}" ]]; then
            ez_print_log -l ERROR -m "\"${command}\" does not exist!"
        else
            ez_print_log -l INFO -m "\"${command}\" looks good!"
        fi
    done
}