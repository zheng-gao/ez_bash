#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_FUNCTION_HELP_KEYWORD="--help"
export EZ_BASH_NON_SPACE_LIST_DELIMITER="#"

export EZ_BASH_SUPPORTED_ARGUMENT_TYPE_DEFAULT="String"
declare -A EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET=(
    ["${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_DEFAULT}"]="${EZ_BASH_BOOL_TRUE}"
    ["List"]="${EZ_BASH_BOOL_TRUE}"
    ["Flag"]="${EZ_BASH_BOOL_TRUE}"
)
export EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET_STRING="$(sed 's/ /, /g' <<< ${!EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET[@]})"

# Do NOT move the following accociative arrays to other files
declare -A EZ_BASH_FUNCTION_SET
# Key Format: function + "::" + long name
declare -A EZ_BASH_FUNCTION_LONG_NAMES_SET
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP
# Key Format: function + "::" + short name
declare -A EZ_BASH_FUNCTION_SHORT_NAMES_SET
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP
declare -A EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP
# Key Format: function
declare -A EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP
declare -A EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP

# MUST unset the above accociative arrays inside a function for each key
function ez_unset_core_accociative_arrays() {
    # Function
    for k in "${!EZ_BASH_FUNCTION_SET[@]}"; do unset EZ_BASH_FUNCTION_SET["${k}"]; done
    # Long/Short Argument Names
    for k in "${!EZ_BASH_FUNCTION_LONG_NAMES_SET[@]}"; do unset EZ_BASH_FUNCTION_LONG_NAMES_SET["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_SHORT_NAMES_SET[@]}"; do unset EZ_BASH_FUNCTION_SHORT_NAMES_SET["${k}"]; done
    # Long Argument Attributes
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP["${k}"]; done
    # Short Argument Attribute
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP[@]}"; do unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP["${k}"]; done
    # Long/Short Matching
    for k in "${!EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[@]}"; do unset EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${k}"]; done
    for k in "${!EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[@]}"; do unset EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${k}"]; done
}

# Source this file should clean all these  accociative arrays
ez_unset_core_accociative_arrays

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_log_stack() {
    local function_stack=""
    if [[ -z "${1}" ]]; then
        # ignore self "ez_log_stack"
        for ((i = ${#FUNCNAME[@]} - 1; i > 0; i--)); do function_stack+="[${FUNCNAME[$i]}]"; done
    else
        # ignore top x
        for ((i = ${#FUNCNAME[@]} - 1; i > "${1}"; i--)); do function_stack+="[${FUNCNAME[$i]}]"; done
    fi
    echo "${function_stack}"
}

function ez_log_error() {
    (>&2 echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZ_BASH_LOG_LOGO}]$(ez_log_stack 1)[ERROR] ${@}")
}

function ez_ask_for_help() {
    if [[ -z "${@}" ]]; then return; fi
    for arg in "${@}"; do
        if [[ "${arg}" == "${EZ_BASH_FUNCTION_HELP_KEYWORD}" ]]; then return; fi
    done
    return 1
}

function ez_set_argument() {
    ### [To Do] Check if the arg already be set to make it faster ###
    local usage_string=$(ez_build_usage -o "init" -d "Register Function Argument")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--function" -d "Function Name")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--type" -d "Supported Types: [${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET_STRING}], default = \"${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_DEFAULT}\"")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-r|--required" -d "Flag for required argument")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--default" -d "Default Value")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--choices" -d "Choices for the argument")
    usage_string+=$(ez_build_usage -o "add" -a "-i|--info" -d "Argument Description")
    declare -A arg_set
    arg_set["-f"]="1"; arg_set["--function"]="1"; arg_set["-t"]="1"; arg_set["--type"]="1"
    arg_set["-s"]="1"; arg_set["--short"]="1"; arg_set["-l"]="1"; arg_set["--long"]="1"
    arg_set["-d"]="1"; arg_set["--default"]="1"; arg_set["-c"]="1"; arg_set["--choices"]="1"
    arg_set["-i"]="1"; arg_set["--info"]="1"
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return; fi
    local function=""
    local type="${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_DEFAULT}"
    local required="${EZ_BASH_BOOL_FALSE}"
    local short=""
    local long=""
    local info=""
    local default=()
    local choices=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-f" | "--function") shift; function=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-t" | "--type") shift; type=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--short") shift; short=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-l" | "--long") shift; long=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-i" | "--info") shift; info=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-r" | "--required") shift; required="${EZ_BASH_BOOL_TRUE}" ;;
            "-d" | "--default") shift;
                while [[ ! -z "${1-}" ]]; do
                    if [[ ! -z "${arg_set[${1-}]}" ]]; then break; fi
                    default+=("${1-}"); shift
                done ;;
            "-c" | "--choices") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ ! -z "${arg_set[${1-}]}" ]]; then break; fi
                    choices+=("${1-}"); shift
                done ;;
            *) ez_log_error "Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    if [[ -z "${short}" ]] && [[ -z "${long}" ]]; then
        ez_log_error "Must provide one of the \"-s|--short\" or \"-l|--long\""; return 1
    fi
    if [[ -z "${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET[${type}]}" ]]; then
        ez_log_error "Invalid value \"${type}\" for \"-t|--type\""
        ez_log_error "Please choose from [${EZ_BASH_SUPPORTED_ARGUMENT_TYPE_SET_STRING}]"
        return 1
    fi
    # EZ_BASH_FUNCTION_HELP="--help" is reserved for ez_bash function help
    if [[ "${short}" == "${EZ_BASH_FUNCTION_HELP_KEYWORD}" ]] || [[ "${long}" == "${EZ_BASH_FUNCTION_HELP_KEYWORD}" ]]; then
        ez_log_error "Invalid argument identifier \"${EZ_BASH_FUNCTION_HELP_KEYWORD}\", which is an EZ-BASH reserved keyword"
        return 2
    fi
    local delimiter="${EZ_BASH_NON_SPACE_LIST_DELIMITER}"
    # If the key has already been registered, then skip
    if [[ ! -z "${short}" ]] && [[ ! -z "${long}" ]]; then
        [[ ! -z "${EZ_BASH_FUNCTION_SHORT_NAMES_SET[${function}${delimiter}${short}]}" ]] &&
        [[ ! -z "${EZ_BASH_FUNCTION_LONG_NAMES_SET[${function}${delimiter}${long}]}" ]] && return
    elif [[ ! -z "${short}" ]]; then
        [[ ! -z "${EZ_BASH_FUNCTION_SHORT_NAMES_SET[${function}${delimiter}${short}]}" ]] && return
    else
        [[ ! -z "${EZ_BASH_FUNCTION_LONG_NAMES_SET[${function}${delimiter}${long}]}" ]] && return
    fi
    local default_str=""; local count=0
    for item in "${default[@]}"; do 
        [[ "${count}" -eq 0 ]] && default_str="${item}" || default_str+="${delimiter}${item}"; ((++count))
    done
    local choices_str=""; count=0
    for item in "${choices[@]}"; do 
        [[ "${count}" -eq 0 ]] && choices_str="${item}" || choices_str+="${delimiter}${item}"; ((++count))
    done
    # Register Function
    EZ_BASH_FUNCTION_SET["${function}"]="${EZ_BASH_BOOL_TRUE}"
    local key=""
    if [[ -z "${short}" ]]; then
        key="${function}${delimiter}${long}"
        local short_old="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${key}]}"
        if [[ -z "${short_old}" ]]; then
            key="${function}${delimiter}${short_old}"
            # Delete short_old
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP["${key}"]
            unset EZ_BASH_FUNCTION_SHORT_NAMES_SET["${key}"]
            local new_short_list_string=""
            for existing_short in $(sed "s/${delimiter}/ /g" <<< "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}"); do
                if [[ "${short_old}" != "${existing_short}" ]]; then
                    if [[ "${new_short_list_string}" == "" ]]; then 
                        new_short_list_string="${existing_short}"
                    else
                        new_short_list_string+="${delimiter}${existing_short}"
                    fi
                fi
            done
            EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]="${new_short_list_string}"
        fi
    else
        key="${function}${delimiter}${short}"
        EZ_BASH_FUNCTION_SHORT_NAMES_SET["${key}"]="${EZ_BASH_BOOL_TRUE}"
        if [[ -z "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}" ]]; then
            EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]="${short}"
        else
            if [[ -z "${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[${key}]}" ]]; then
                EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP["${function}"]+="${delimiter}${short}"
            fi
        fi
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP["${key}"]="${long}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP["${key}"]="${type}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP["${key}"]="${required}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]="${info}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]="${default_str[@]}"
        EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP["${key}"]="${choices_str[@]}"
    fi
    if [[ -z "${long}" ]]; then
        key="${function}${delimiter}${short}"
        local long_old="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${key}]}"
        if [[ ! -z "${long_old}" ]]; then
            key="${function}${delimiter}${long_old}"
            # Delete long_old
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]
            unset EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP["${key}"]
            unset EZ_BASH_FUNCTION_LONG_NAMES_SET["${key}"]
            local new_long_list_string=""
            for existing_long in $(sed "s/${delimiter}/ /g" <<< "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [[ "${new_short_list_string}" == "" ]]; then 
                        new_long_list_string="${existing_long}"
                    else
                        new_long_list_string+="${delimiter}${existing_long}"
                    fi
                fi
            done
            EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]="${new_long_list_string}"
        fi
    else
        key="${function}${delimiter}${long}"
        EZ_BASH_FUNCTION_LONG_NAMES_SET["${key}"]="${EZ_BASH_BOOL_TRUE}"
        if [[ -z "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}" ]]; then
            EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]="${long}"
        else
            if [[ -z "${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[${key}]}" ]]; then
                EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP["${function}"]+="${delimiter}${long}"
            fi
        fi
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP["${key}"]="${short}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP["${key}"]="${type}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP["${key}"]="${required}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]="${info}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]="${default_str[@]}"
        EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP["${key}"]="${choices_str[@]}"
    fi
}

function ez_get_argument() {
    local usage_string=$(ez_build_usage -o "init" -d "Get argument value from argument list")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
    usage_string+=$(ez_build_usage -o "add" -a "-a|--arguments" -d "Argument List")
    usage_string+="\n[Notes]\n"
    usage_string+="    Can only be called by another function"
    usage_string+="    The arguments to process must be at the end of this function's argument list\n"
    usage_string+="[Example]\n"
    usage_string+="    ${FUNCNAME[0]} -s|--short \${SHORT_ARG} -l|--long \${LONG_ARG} -a|--arguments \"\${@}\"\n"
    if [[ -z "${1}" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then  ez_print_usage "${usage_string}"; return; fi
    # Must Run Inside Other Functions
    local function="${FUNCNAME[1]}"
    if [[ -z "${EZ_BASH_FUNCTION_SET[${function}]}" ]]; then ez_log_error "Function \"${function}\" NOT registered"; return 2; fi
    local short=""
    local long=""
    local arguments=()
    if [[ "${1}" == "-s" ]] || [[ "${1}" == "--short" ]]; then
        short="${2}"
        if [[ "${3}" == "-l" ]] || [[ "${3}" == "--long" ]]; then
            long="${4}"
            if [[ "${5}" == "-a" ]] || [[ "${5}" == "--arguments" ]]; then
                local count=1
                while [[ ! -z "${1-}" ]]; do [[ "${count}" -gt 5 ]] && arguments+=("${1}"); shift; ((++count)); done
            else
                ez_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez_print_usage "${usage_string}"
                return 1
            fi
        elif [[ "${3}" == "-a" ]] || [[ "${3}" == "--arguments" ]]; then
            local count=1
            while [[ ! -z "${1-}" ]]; do [[ "${count}" -gt 3 ]] && arguments+=("${1}"); shift; ((++count)); done
        else
            ez_log_error "Invalid argument identifier \"${3}\", expected \"-l|--long\" or \"-a|--arguments\""
            ez_print_usage "${usage_string}"
            return 1
        fi
    elif [[ "${1}" == "-l" ]] || [[ "${1}" == "--long" ]]; then
        long="${2}"
        if [[ "${3}" == "-s" ]] || [[ "${3}" == "--short" ]]; then
            short="${4}"
            if [[ "${5}" == "-a" ]] || [[ "${5}" == "--arguments" ]]; then
                local count=1
                while [[ ! -z "${1-}" ]]; do [[ "${count}" -gt 5 ]] && arguments+=("${1}"); shift; ((++count)); done
            else
                ez_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez_print_usage "${usage_string}"
                return 1
            fi
        elif [[ "${3}" == "-a" ]] || [[ "${3}" == "--arguments" ]]; then
            local count=1
            while [[ ! -z "${1-}" ]]; do [[ "${count}" -gt 3 ]] && arguments+=("${1}"); shift; ((++count)); done
        else
            ez_log_error "Invalid argument identifier \"${5}\", expected \"-s|--short\" or \"-a|--arguments\""
            ez_print_usage "${usage_string}"
            return 1
        fi
    else
        ez_log_error "Invalid argument identifier \"${1}\", expected \"-s|--short\" or \"-l|--long\""
        ez_print_usage "${usage_string}"
        return 1
    fi
    if [[ -z "${short}" ]] && [[ -z "${long}" ]]; then ez_log_error "Not found \"-s|--short\" or \"-l|--long\""; return 1; fi
    local short_key=""
    local long_key=""
    if [[ ! -z "${short}" ]]; then
        short_key="${function}${EZ_BASH_NON_SPACE_LIST_DELIMITER}${short}"
        if [[ -z "${EZ_BASH_FUNCTION_SHORT_NAMES_SET[${short_key}]}" ]]; then
            ez_log_error "\"${short}\" has NOT been registered as short identifier for function \"${function}\""; return 2
        fi
    fi
    if [[ ! -z "${long}" ]]; then
        long_key="${function}${EZ_BASH_NON_SPACE_LIST_DELIMITER}${long}"
        if [[ -z "${EZ_BASH_FUNCTION_LONG_NAMES_SET[${long_key}]}" ]]; then
            ez_log_error "\"${long}\" has NOT been registered as long identifier for function \"${function}\""; return 2
        fi
    fi
    if [[ ! -z "${short}" ]] && [[ ! -z "${long}" ]]; then
        # Check short/long pair matches 
        if [[ "${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${long_key}]}" != "${short}" ]] || [[ "${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${short_key}]}" != "${long}" ]]; then
            ez_log_error "The Arg-Short identifier \"${short}\" and the Arg-Long identifier \"${long}\" does not match the registration of function \"${function}\""
            ez_log_error "Registered Pair: Arg-Short \"${short}\" -> Arg-Long \"${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${short_key}]}\""
            ez_log_error "Registered Pair: Arg-Long \"${long}\" -> Arg-Short \"${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${long_key}]}\""
            return 2
        fi
    fi
    local argument_type=""
    local argument_default=""
    local argument_choices=""
    if [[ ! -z "${short}" ]]; then
        argument_required="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP[${short_key}]}"
        argument_type="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[${short_key}]}"
        argument_default="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP[${short_key}]}"
        argument_choices="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP[${short_key}]}"
    else
        argument_required="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP[${long_key}]}"
        argument_type="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[${long_key}]}"
        argument_default="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP[${long_key}]}"
        argument_choices="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP[${long_key}]}"   
    fi
    local delimiter="${EZ_BASH_NON_SPACE_LIST_DELIMITER}"
    if [[ -z "${argument_type}" ]]; then ez_log_error "Arg-Type for \"${short}\" or \"${long}\" of function \"${function}\" Not Found"; return 3; fi
    if [[ "${argument_type}" == "Flag" ]]; then
        for item in ${arguments[@]}; do
            if [[ "${item}" == "${short}" ]] || [[ "${item}" == "${long}" ]]; then
                echo "${EZ_BASH_BOOL_TRUE}"; return
            fi
        done
        echo "${EZ_BASH_BOOL_FALSE}"; return
    elif [[ "${argument_type}" == "String" ]]; then
        for ((i = 0; i < ${#arguments[@]} - 1; i++)); do
            local name="${arguments[${i}]}"
            if [[ "${arguments[${i}]}" == "${short}" ]] || [[ "${arguments[${i}]}" == "${long}" ]]; then
                ((i++))
                local value="${arguments[${i}]}"
                if [[ ! -z "${argument_choices}" ]]; then
                    declare -A choice_set
                    local choice=""
                    local length="${#argument_choices}"
                    local last_index=0; ((last_index=length-1))
                    for ((k=0; k < "${length}"; ++k)); do
                        local char="${argument_choices:k:1}"
                        if [[ "${char}" == "${delimiter}" ]]; then
                            [[ ! -z "${choice}" ]] && choice_set["${choice}"]="${EZ_BASH_BOOL_TRUE}"
                            choice=""
                        else
                            choice+="${char}"
                        fi
                        [[ "${k}" -eq "${last_index}" ]] && [[ ! -z "${choice}" ]] && choice_set["${choice}"]="${EZ_BASH_BOOL_TRUE}"
                    done
                    if [[ -z "${choice_set[${value}]}" ]]; then
                        local choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ez_log_error "Invalide value \"${value}\" for argument \"${name}\", please choose from [${choices_string}]"
                        return 4
                    fi
                fi
                # No Choices Restriction
                echo "${value}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && [[ "${argument_required}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            [[ ! -z "${short}" ]] && ez_log_error "Argument \"${short}\" is required"
            [[ ! -z "${long}" ]] && ez_log_error "Argument \"${long}\" is required"
            return 5
        fi
        # Not Found, Use Default, Only print the first item in the default list
        local default_value=""
        local length="${#argument_default}"
        local last_index=0; ((last_index=length-1))
        for ((k=0; k < "${length}"; ++k)); do
            local char="${argument_default:k:1}"
            if [[ "${char}" == "${delimiter}" ]]; then
                [[ ! -z "${default_value}" ]] && echo "${default_value}"
                return
            else
                default_value+="${char}"
            fi
            [[ "${k}" -eq "${last_index}" ]] && [[ ! -z "${default_value}" ]] && echo "${default_value}"
        done
    elif [[ "${argument_type}" == "List" ]]; then
        for ((i = 0; i < ${#arguments[@]} - 1; i++)); do
            local name="${arguments[${i}]}"
            if [[ "${arguments[${i}]}" == "${short}" ]] || [[ "${arguments[${i}]}" == "${long}" ]]; then
                local output_list_string=""; local count=0
                for ((j=1; i + j < ${#arguments[@]}; j++)); do
                    local index=$((i + j))
                    # List ends with another argument indentifier "-" or end of line
                    if [[ "${arguments[${index}]}" =~ "-"[-,a-zA-Z].* ]]; then break; fi
                    if [[ "${count}" == 0 ]]; then
                        output_list_string="${arguments[${index}]}"
                    else
                        output_list_string+="${delimiter}${arguments[${index}]}"
                    fi
                    ((++count))
                done
                echo "${output_list_string}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && [[ "${argument_required}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            [[ ! -z "${short}" ]] && ez_log_error "Argument \"${short}\" is required"
            [[ ! -z "${long}" ]] && ez_log_error "Argument \"${long}\" is required"
            return 5
        fi
        # Not Found, Use Default
        echo "${argument_default}"
    fi
}

function ez_function_help() {
    local usage_string=$(ez_build_usage -o "init" -d "Check if the function is registered")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--function" -d "Function Name")
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return; fi
    local function="${FUNCNAME[1]}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-f" | "--function") shift; function=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            *) ez_log_error "Unknown argument \"${1}\""; ez_print_usage "${usage_string}"; return 1 ;;
        esac
    done
    if [[ -z "${function}" ]]; then function="${FUNCNAME[1]}"; fi
    if [[ -z "${EZ_BASH_FUNCTION_SET[${function}]}" ]]; then ez_log_error "Function \"${function}\" NOT registered"; return 2; fi
    local delimiter="${EZ_BASH_NON_SPACE_LIST_DELIMITER}"
    echo
    echo "[Function Name] \"${function}\""
    echo
    {
        echo "[Arg Short]${delimiter}[Arg Long]${delimiter}[Arg Type]${delimiter}[Arg Required]${delimiter}[Arg Default]${delimiter}[Arg Choices]${delimiter}[Arg Description]"
        for short in $(sed "s/${delimiter}/ /g" <<< "${EZ_BASH_FUNCTION_NAME_TO_SHORT_NAMES_MAP[${function}]}"); do
            local key="${function}${delimiter}${short}"
            local long="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_LONG_NAME_MAP[${key}]}"
            [[ -z "${long}" ]] && long="${EZ_BASH_NONE}"
            local type="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_TYPE_MAP[${key}]}"
            [[ -z "${type}" ]] && type="${EZ_BASH_NONE}"
            local required="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_REQUIRED_MAP[${key}]}"
            [[ -z "${required}" ]] && required="${EZ_BASH_NONE}"
            local choices="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_CHOICES_MAP[${key}]}"
            if [[ -z "${choices}" ]]; then
                choices="${EZ_BASH_NONE}"
            else
                choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            fi
            local default="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP["${key}"]}"
            if [[ -z "${default}" ]]; then
                default="${EZ_BASH_NONE}"
            else
                default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            fi
            local info="${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_INFO_MAP["${key}"]}"
            [[ -z "${info}" ]] && info="${EZ_BASH_NONE}"
            echo "${short}${delimiter}${long}${delimiter}${type}${delimiter}${required}${delimiter}${default}${delimiter}${choices}${delimiter}${info}"
        done
        for long in $(sed "s/${delimiter}/ /g" <<< "${EZ_BASH_FUNCTION_NAME_TO_LONG_NAMES_MAP[${function}]}"); do
            local key="${function}${delimiter}${long}"
            local short="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_SHORT_NAME_MAP[${key}]}"
            local type="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_TYPE_MAP[${key}]}"
            [[ -z "${type}" ]] && type="${EZ_BASH_NONE}"
            local required="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_REQUIRED_MAP[${key}]}"
            [[ -z "${required}" ]] && required="${EZ_BASH_NONE}"
            local choices="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_CHOICES_MAP[${key}]}"
            if [[ -z "${choices}" ]]; then
                choices="${EZ_BASH_NONE}"
            else
                choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            fi
            local default="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_DEFAULT_MAP["${key}"]}"
            if [[ -z "${default}" ]]; then
                default="${EZ_BASH_NONE}"
            else
                default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            fi
            local info="${EZ_BASH_FUNCTION_ARGUMENT_LONG_NAME_TO_INFO_MAP["${key}"]}"
            [[ -z "${info}" ]] && info="${EZ_BASH_NONE}"
            if [[ -z "${short}" ]]; then
                short="${EZ_BASH_NONE}"
                echo "${short}${delimiter}${long}${delimiter}${type}${delimiter}${required}${delimiter}${default}${delimiter}${choices}${delimiter}${info}"
            fi
        done
    } | column -t -s "${delimiter}"
    echo
}

