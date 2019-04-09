#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

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
            *) echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1; ;;
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

function ez_source() {
    if [[ "${1}" == "" ]]; then echo "[EZ-BASH][ERROR] Empty file path"; return 1; fi
    local file_path="${1}"
    if [ ! -f "${file_path}" ]; then echo "[EZ-BASH][ERROR] Invalid file path \"${file_path}\""; return 2; fi
    if [ ! -r "${file_path}" ]; then echo "[EZ-BASH][ERROR] Unreadable file \"${file_path}\""; return 3; fi
    if ! source "${file_path}"; then echo "[EZ-BASH][ERROR] Failed to source \"${file_path}\""; return 4; fi
}

function ez_source_directory() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_source_directory" -d "Source Directory")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
    usage_string+=$(ez_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local path="."
    local exclude=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-p" | "--path") shift; path=${1-} ;;
            "-r" | "--exclude") shift; exclude=${1-} ;;
            *) echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${path}" == "" ]]; then echo "[EZ-BASH][ERROR] Invalid value \"${path}\" for \"-p|--path\""; return 1; fi
    if [ ! -d "${path}" ]; then echo "[EZ-BASH][ERROR] \"${path}\" is not a directory"; return 2; fi
    if [ ! -r "${path}" ]; then echo "[EZ-BASH][ERROR] Cannot read directory \"${dir_path}\""; return 3; fi
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

function ez_get_argument() {
    # Error Code
    # 1: Invalid Argument Name
    # 2: Invalid Argument Type
    # 3: Argument Value Not Found & Default Not Given
    # 4: Argument Value Not In "Choose From" Set 
    local supported_types=("String" "List" "Boolean")
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_argument" -d "Get argument value from argument list")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-type" -d "Supported Types: [${supported_types[*]}], default = \"String\"")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-short-identifier" -d "Short Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-long-identifier" -d "Long Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-list" -d "Argument List")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-default-value" -d "Default Value")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-choose-from" -d "Valid Option")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local ez_argument_type="String"
    local short_identifier=""
    local long_identifier=""
    local default_value=()
    local use_default_value="${EZ_BASH_BOOL_FALSE}"
    local arguments=()
    declare -A choose_from_set
    local validate_choice="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "--ez-argument-type") shift; ez_argument_type=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-short-identifier") shift; short_identifier=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-long-identifier") shift; long_identifier=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-argument-list") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-short-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-long-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-list" ]]; then break; fi
                    if [[ "${1-}" == "--ez-default-value" ]]; then break; fi
                    if [[ "${1-}" == "--ez-choose-from" ]]; then break; fi
                    arguments+=("${1-}"); shift
                done ;;
            "--ez-default-value") shift
                use_default_value="${EZ_BASH_BOOL_TRUE}"
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-short-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-long-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-list" ]]; then break; fi
                    if [[ "${1-}" == "--ez-default-value" ]]; then break; fi
                    if [[ "${1-}" == "--ez-choose-from" ]]; then break; fi
                    default_value+=("${1-}"); shift
                done ;;
            "--ez-choose-from") shift
                validate_choice="${EZ_BASH_BOOL_TRUE}"
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-short-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-long-identifier" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-list" ]]; then break; fi
                    if [[ "${1-}" == "--ez-default-value" ]]; then break; fi
                    if [[ "${1-}" == "--ez-choose-from" ]]; then break; fi
                    choose_from_set["${1-}"]="${EZ_BASH_BOOL_TRUE}"; shift
                done ;;
            *) echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${ez_argument_type}" == "Boolean" ]]; then
        for item in ${arguments[@]}; do
            if [[ "${item}" == "${short_identifier}" ]] || [[ "${item}" == "${long_identifier}" ]]; then
                echo "${EZ_BASH_BOOL_TRUE}"; return
            fi
        done
        if [[ "${use_default_value}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            if [[ "${default_value[@]}" == "" ]]; then
                return 3
            else
                echo "${default_value[0]}"
            fi
        else
            echo "${EZ_BASH_BOOL_FALSE}"
        fi
    elif [[ "${ez_argument_type}" == "String" ]]; then
        for ((i = 0; i < ${#arguments[@]} - 1; i++)); do
            if [[ "${arguments[${i}]}" == "${short_identifier}" ]] || [[ "${arguments[${i}]}" == "${long_identifier}" ]]; then
                local identifier="${arguments[${i}]}"
                ((i++))
                if [[ "${validate_choice}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
                    if [ ! ${choose_from_set["${arguments[${i}]}"]+_} ]; then
                        echo "[${EZ_BASH_LOG_LOGO}][ERROR] Invalide value \"${arguments[${i}]}\" for identifier \"${identifier}\", please choose from [${!choose_from_set[*]}]"
                        return 4
                    else
                        echo "${arguments[${i}]}"; return
                    fi
                else
                    echo "${arguments[${i}]}"; return
                fi
            fi
        done
        if [[ "${use_default_value}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            if [[ "${default_value[@]}" == "" ]]; then
                return 3
            else
                echo "${default_value[0]}"
            fi
        fi
    elif [[ "${ez_argument_type}" == "List" ]]; then
        for ((i = 0; i < ${#arguments[@]} - 1; i++)); do
            if [[ "${arguments[${i}]}" == "${short_identifier}" ]] || [[ "${arguments[${i}]}" == "${long_identifier}" ]]; then
                # List ends with another argument indentifier "-" or end of line
                for ((j=1; i + j < ${#arguments[@]}; j++)); do
                    local index=$((i + j))
                    if [[ "${arguments[${index}]}" =~ "-"[-,a-zA-Z].* ]]; then break; fi
                    echo "${arguments[${index}]}"
                done
                return
            fi
        done
        if [[ "${use_default_value}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            if [[ "${default_value[@]}" == "" ]]; then
                return 3
            else
                for item in "${default_value[@]}"; do
                    echo "${item}"
                done
            fi
        fi
    else
        echo "[${EZ_BASH_LOG_LOGO}][ERROR] Invalid value \"${ez_argument_type}\" for \"--ez-argument-type\""; ez_print_usage "${usage_string}"
        return 2
    fi
}















