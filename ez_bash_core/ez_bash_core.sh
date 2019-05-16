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
export EZ_BASH_ALL="EZ-ALL"
export EZ_BASH_NONE="EZ-NONE"
export EZ_BASH_DEFAULT_ARGUMENT_TYPES="String"
export EZ_BASH_SUPPORTED_ARGUMENT_TYPES=("${EZ_BASH_DEFAULT_ARGUMENT_TYPES}" "List" "Boolean")

# Do NOT move the following accociative arrays to other files
# Key Format: function + "::" + long name
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP
# Key Format: function + "::" + short name
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP
# Key Format: function
declare -A EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP
declare -A EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP

# MUST unset the above accociative arrays inside a function for each key
function ez_unset_core_accociative_arrays() {
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[@]}"; do unset EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${key}"]; done
    for key in "${!EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[@]}"; do unset EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${key}"]; done
}
# Source this file should clean all these  accociative arrays
ez_unset_core_accociative_arrays

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_print_usage() {
    tabs "${EZ_BASH_TAB_SIZE}"
    printf "${1}"
}

function ez_build_usage() {
    local usage_string="[Function Name]\t\"ez_build_usage\"\n[Function Info]\tEZ-BASH standard usage builder\n"
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
        if [[ "${argument}" == "" ]]; then argument="${FUNCNAME[1]}"; fi
        echo "[Function Name]\t\"${argument}\"\n[Function Info]\t${description}\n"
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
    local usage_string=$(ez_build_usage -o "init" -d "Source Directory")
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
    local usage_string=$(ez_build_usage -o "init" -d "Get argument value from argument list")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-type" -d "Supported Types: [${supported_types[*]}], default = \"String\"")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-short" -d "Short Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-long" -d "Long Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-argument-list" -d "Argument List")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-default-value" -d "Default Value")
    usage_string+=$(ez_build_usage -o "add" -a "--ez-choose-from" -d "Valid Option")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local ez_argument_type="String"
    local argument_short=""
    local argument_long=""
    local default_value=()
    local use_default_value="${EZ_BASH_BOOL_FALSE}"
    local arguments=()
    # The accociated arrays declared in bash script are all global, must unset the choose_from_set before using it
    unset choose_from_set; declare -A choose_from_set
    local validate_choice="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "--ez-argument-type") shift; ez_argument_type=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-argument-short") shift; argument_short=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-argument-long") shift; argument_long=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--ez-argument-list") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-short" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-long" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-list" ]]; then break; fi
                    if [[ "${1-}" == "--ez-default-value" ]]; then break; fi
                    if [[ "${1-}" == "--ez-choose-from" ]]; then break; fi
                    arguments+=("${1-}"); shift
                done ;;
            "--ez-default-value") shift
                use_default_value="${EZ_BASH_BOOL_TRUE}"
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-short" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-long" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-list" ]]; then break; fi
                    if [[ "${1-}" == "--ez-default-value" ]]; then break; fi
                    if [[ "${1-}" == "--ez-choose-from" ]]; then break; fi
                    default_value+=("${1-}"); shift
                done ;;
            "--ez-choose-from") shift
                validate_choice="${EZ_BASH_BOOL_TRUE}"
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "--ez-argument-type" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-short" ]]; then break; fi
                    if [[ "${1-}" == "--ez-argument-long" ]]; then break; fi
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
            if [[ "${item}" == "${argument_short}" ]] || [[ "${item}" == "${argument_long}" ]]; then
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
            if [[ "${arguments[${i}]}" == "${argument_short}" ]] || [[ "${arguments[${i}]}" == "${argument_long}" ]]; then
                local name="${arguments[${i}]}"
                ((i++))
                if [[ "${validate_choice}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
                    if [ ! ${choose_from_set["${arguments[${i}]}"]+_} ]; then
                        echo "[${EZ_BASH_LOG_LOGO}][ERROR] Invalide value \"${arguments[${i}]}\" for name \"${name}\", please choose from [${!choose_from_set[*]}]"
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
            if [[ "${arguments[${i}]}" == "${argument_short}" ]] || [[ "${arguments[${i}]}" == "${argument_long}" ]]; then
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

function ez_argument_register() {
    local non_space_delimiter="+" # Cannot Be SPACE
    local usage_string=$(ez_build_usage -o "init" -d "Register Function Argument")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--function" -d "Function Name")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--type" -d "Supported Types: [${EZ_BASH_SUPPORTED_ARGUMENT_TYPES[*]}], default = \"${EZ_BASH_DEFAULT_ARGUMENT_TYPES}\"")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--default" -d "Default Value")
    usage_string+=$(ez_build_usage -o "add" -a "-i|--info" -d "Argument Description")
    usage_string+=$(ez_build_usage -o "add" -a "--get-delimiter" -d "Print \"${non_space_delimiter}\"")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local function=""
    local type="${EZ_BASH_DEFAULT_ARGUMENT_TYPES}"
    local short=""
    local long=""
    local default="NO_DEFAULT_VALUE"
    local info="NO_ARGUMENT_DESCRIPTION"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-f" | "--function") shift; function=${1-} ;;
            "-t" | "--type") shift; type=${1-} ;;
            "-s" | "--short") shift; short=${1-} ;;
            "-l" | "--long") shift; long=${1-} ;;
            "-d" | "--default") shift; default=${1-} ;;
            "-i" | "--info") shift; info=${1-} ;;
            "--get-delimiter") echo "${non_space_delimiter}"; return ;;
            *)
                echo "[${EZ_BASH_LOG_LOGO}][${FUNCNAME[0]}][ERROR] Unknown argument \"${1}\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${function}" == "" ]]; then function="${FUNCNAME[1]}"; fi
    if [[ "${short}" == "" ]] && [[ "${long}" == "" ]]; then
        echo "[EZ-BASH][${FUNCNAME[0]}][ERROR] Must provide one of the \"-s|--short\" or \"-l|--long\""; return 1
    fi
    local is_supported_type="${EZ_BASH_BOOL_FALSE}"
    for supported_type in ${EZ_BASH_SUPPORTED_ARGUMENT_TYPES[@]}; do
        if [[ "${type}" == "${supported_type}" ]]; then
            is_supported_type="${EZ_BASH_BOOL_TRUE}"
            break
        fi
    done 
    if [[ "${is_supported_type}" == "${EZ_BASH_BOOL_FALSE}" ]]; then
        echo "[EZ-BASH][${FUNCNAME[0]}][ERROR] Invalid value \"${type}\" for \"-t|--type\", please choose from [${EZ_BASH_SUPPORTED_ARGUMENT_TYPES[*]}]"
        return 1
    fi
    local key=""
    if [[ "${short}" == "" ]]; then
        key="${function}${non_space_delimiter}${long}"
        local short_old="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${key}]}"
        if [[ "${short_old}" != "" ]]; then
            key="${function}${non_space_delimiter}${short_old}"
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]
            # Delete short_old from the short_list
            local new_short_list_string=""
            for existing_short in $(echo "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}" | column -t -s "${non_space_delimiter}"); do
                if [[ "${short_old}" != "${existing_short}" ]]; then
                    if [[ "${new_short_list_string}" == "" ]]; then 
                        new_short_list_string="${existing_short}"
                    else
                        new_short_list_string+="${non_space_delimiter}${existing_short}"
                    fi
                fi
            done
            EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]="${new_short_list_string}"
        fi
    else
        key="${function}${non_space_delimiter}${short}"
        if [[ -z "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}" ]]; then
            EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]="${short}"
        else
            if [[ -z "${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[${key}]}" ]]; then
                EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]+="${non_space_delimiter}${short}"
            fi
        fi
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${key}"]="${long}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${key}"]="${type}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]="${default}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]="${info}"
    fi
    if [[ "${long}" == "" ]]; then
        key="${function}${non_space_delimiter}${short}"
        local long_old="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${key}]}"
        if [[ "${long_old}" != "" ]]; then
            key="${function}${non_space_delimiter}${long_old}"
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]
            # Delete long_old from the long_list
            local new_long_list_string=""
            for existing_long in $(echo "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}" | column -t -s "${non_space_delimiter}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [[ "${new_short_list_string}" == "" ]]; then 
                        new_long_list_string="${existing_long}"
                    else
                        new_long_list_string+="${non_space_delimiter}${existing_long}"
                    fi
                fi
            done
            EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]="${new_long_list_string}"
        fi
    else
        key="${function}${non_space_delimiter}${long}"
        if [[ -z "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}" ]]; then
            EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]="${long}"
        else
            if [[ -z "${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[${key}]}" ]]; then
                EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]+="${non_space_delimiter}${long}"
            fi
        fi
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${key}"]="${short}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${key}"]="${type}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]="${default}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]="${info}"
    fi
}

function ez_function_help() {
    local function="${1}"
    if [[ "${function}" == "" ]]; then function="${FUNCNAME[1]}"; fi
    if [[ "${function}" == "" ]]; then echo "[EZ-BASH][ERROR] Empty Function Name \"${function}\" for \${1}"; return 2; fi
    if [[ -z "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}" ]] && [[ -z "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}" ]]; then
        echo "[EZ-BASH][ERROR] Function Name \"${function}\" Has Not Been Registered"
        return 1
    fi
    local delimiter="$(ez_argument_register --get-delimiter)"
    local col_delimiter="#"
    echo
    echo "[Function Name] \"${function}\""
    echo
    {
        echo "[Short Arg]${col_delimiter}[Long Arg]${col_delimiter}[Arg Type]${col_delimiter}[Default Value]${col_delimiter}[Arg Description]"
        for short in $(echo "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}" | column -t -s "${delimiter}"); do
            local key="${function}${delimiter}${short}"
            local long="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${key}]}"
            local type="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[${key}]}"
            local default="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]}"
            local info="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]}"
            if [[ -z "${long}" ]]; then
                echo "${short}${col_delimiter}None${col_delimiter}${type}${col_delimiter}${default}${col_delimiter}${info}"
            else
                echo "${short}${col_delimiter}${long}${col_delimiter}${type}${col_delimiter}${default}${col_delimiter}${info}"
            fi
        done
        for long in $(echo "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}" | column -t -s "${delimiter}"); do
            local key="${function}${delimiter}${long}"
            local short="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${key}]}" 
            local type="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[${key}]}"
            local default="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]}"
            local info="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]}"
            if [[ -z "${short}" ]]; then
                echo "None${col_delimiter}${long}${col_delimiter}${type}${col_delimiter}${default}${col_delimiter}${info}"
            fi
        done
    } | column -t -s "${col_delimiter}"
    echo
}
