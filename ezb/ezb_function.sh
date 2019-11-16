###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_FUNC_HELP="--help"
EZB_ARG_TYPE_DEFAULT="String"
declare -g -A EZB_ARG_TYPE_SET=(
    ["${EZB_ARG_TYPE_DEFAULT}"]="${EZB_BOOL_TRUE}"
    ["List"]="${EZB_BOOL_TRUE}"
    ["Flag"]="${EZB_BOOL_TRUE}"
)

# Do NOT move the following accociative arrays to other files
declare -g -A EZB_FUNC_SET
# Key Format: function + "::" + long name
declare -g -A EZB_FUNC_L_ARG_SET
declare -g -A EZB_FUNC_L_ARG_TO_S_ARG_MAP
declare -g -A EZB_FUNC_L_ARG_TO_TYPE_MAP
declare -g -A EZB_FUNC_L_ARG_TO_REQUIRED_MAP
declare -g -A EZB_FUNC_L_ARG_TO_DEFAULT_MAP
declare -g -A EZB_FUNC_L_ARG_TO_INFO_MAP
declare -g -A EZB_FUNC_L_ARG_TO_CHOICES_MAP
# Key Format: function + "::" + short name
declare -g -A EZB_FUNC_S_ARG_SET
declare -g -A EZB_FUNC_S_ARG_TO_L_ARG_MAP
declare -g -A EZB_FUNC_S_ARG_TO_TYPE_MAP
declare -g -A EZB_FUNC_S_ARG_TO_REQUIRED_MAP
declare -g -A EZB_FUNC_S_ARG_TO_DEFAULT_MAP
declare -g -A EZB_FUNC_S_ARG_TO_INFO_MAP
declare -g -A EZB_FUNC_S_ARG_TO_CHOICES_MAP
# Key Format: function
declare -g -A EZB_FUNC_TO_L_ARG_MAP
declare -g -A EZB_FUNC_TO_S_ARG_MAP

# MUST unset the above accociative arrays inside a function for each key
function ezb_function_unset_accociative_arrays() {
    local k=""
    # Function
    for k in "${!EZB_FUNC_SET[@]}"; do unset EZB_FUNC_SET["${k}"]; done
    # Long/Short Argument Names
    for k in "${!EZB_FUNC_L_ARG_SET[@]}"; do unset EZB_FUNC_L_ARG_SET["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_SET[@]}"; do unset EZB_FUNC_S_ARG_SET["${k}"]; done
    # Long Argument Attributes
    for k in "${!EZB_FUNC_L_ARG_TO_S_ARG_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_S_ARG_MAP["${k}"]; done
    for k in "${!EZB_FUNC_L_ARG_TO_TYPE_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_TYPE_MAP["${k}"]; done
    for k in "${!EZB_FUNC_L_ARG_TO_REQUIRED_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_REQUIRED_MAP["${k}"]; done
    for k in "${!EZB_FUNC_L_ARG_TO_DEFAULT_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_DEFAULT_MAP["${k}"]; done
    for k in "${!EZB_FUNC_L_ARG_TO_INFO_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_INFO_MAP["${k}"]; done
    for k in "${!EZB_FUNC_L_ARG_TO_CHOICES_MAP[@]}"; do unset EZB_FUNC_L_ARG_TO_CHOICES_MAP["${k}"]; done
    # Short Argument Attribute
    for k in "${!EZB_FUNC_S_ARG_TO_L_ARG_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_L_ARG_MAP["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_TO_TYPE_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_TYPE_MAP["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_TO_REQUIRED_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_REQUIRED_MAP["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_TO_DEFAULT_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_DEFAULT_MAP["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_TO_INFO_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_INFO_MAP["${k}"]; done
    for k in "${!EZB_FUNC_S_ARG_TO_CHOICES_MAP[@]}"; do unset EZB_FUNC_S_ARG_TO_CHOICES_MAP["${k}"]; done
    # Long/Short Matching
    for k in "${!EZB_FUNC_TO_L_ARG_MAP[@]}"; do unset EZB_FUNC_TO_L_ARG_MAP["${k}"]; done
    for k in "${!EZB_FUNC_TO_S_ARG_MAP[@]}"; do unset EZB_FUNC_TO_S_ARG_MAP["${k}"]; done
}

# Source this file should clean all these accociative arrays
# Do not source this file more than once
ezb_function_unset_accociative_arrays

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_function_exist() {
    # Should only be called by another function. If not, give the function name in 1st argument
    if [[ -z "${1}" ]]; then
        [[ -z "${EZB_FUNC_SET[${FUNCNAME[1]}]}" ]] && return 1
        [[ "${EZB_FUNC_SET[${FUNCNAME[1]}]}" != "${EZB_BOOL_TRUE}" ]] && return 1
    else
        [[ -z "${EZB_FUNC_SET[${1}]}" ]] && return 1
        [[ "${EZB_FUNC_SET[${1}]}" != "${EZB_BOOL_TRUE}" ]] && return 1
    fi
}

function ezb_function_check_help_keyword() {
    [ -z "${1}" ] && return 0 # Print help info if no argument given
    ezb_exclude "${EZB_FUNC_HELP}" "${@}" && return 1 || return 0
}

function ezb_function_print_help() {
    if [ "${1}" = "-h" -o "${1}" = "--help" ]; then
        local usage=$(ezb_build_usage -o "init" -d "Check if the function is registered")
        usage+=$(ezb_build_usage -o "add" -a "-f|--function" -d "Function Name")
        ezb_print_usage "${usage}"
        return
    fi
    # Should only be called by another function
    local function="${FUNCNAME[1]}"
    while [ -n "${1}" ]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; [ -n "${1}" ] && shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [ -z "${function}" ] && function="${FUNCNAME[1]}"
    [ -z "${EZB_FUNC_SET[${function}]}" ] && ezb_log_error "Function \"${function}\" NOT registered" && return 2
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    echo; echo "[Function Name] \"${function}\""; echo
    {
        echo $(ezb_join "${delimiter}" "[Short]" "[Long]" "[Type]" "[Required]" "[Default]" "[Choices]" "[Description]")
        local key=""; local short=""; local long=""; local type=""; local required=""; local choices=""; local default=""; local info=""
        for short in $(sed "s/${delimiter}/ /g" <<< "${EZB_FUNC_TO_S_ARG_MAP[${function}]}"); do
            key="${function}${delimiter}${short}"
            long="${EZB_FUNC_S_ARG_TO_L_ARG_MAP[${key}]}"; [ -z "${long}" ] && long="${EZB_OPT_NONE}"
            type="${EZB_FUNC_S_ARG_TO_TYPE_MAP[${key}]}"; [ -z "${type}" ] && type="${EZB_OPT_NONE}"
            required="${EZB_FUNC_S_ARG_TO_REQUIRED_MAP[${key}]}"; [ -z "${required}" ] && required="${EZB_OPT_NONE}"
            choices="${EZB_FUNC_S_ARG_TO_CHOICES_MAP[${key}]}"; [ -z "${choices}" ] && choices="${EZB_OPT_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZB_FUNC_S_ARG_TO_DEFAULT_MAP["${key}"]}"; [ -z "${default}" ] && default="${EZB_OPT_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZB_FUNC_S_ARG_TO_INFO_MAP["${key}"]}"; [ -z "${info}" ] && info="${EZB_OPT_NONE}"
            echo $(ezb_join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${default}" "${choices}" "${info}")
        done
        for long in $(sed "s/${delimiter}/ /g" <<< "${EZB_FUNC_TO_L_ARG_MAP[${function}]}"); do
            key="${function}${delimiter}${long}"
            short="${EZB_FUNC_L_ARG_TO_S_ARG_MAP[${key}]}"
            type="${EZB_FUNC_L_ARG_TO_TYPE_MAP[${key}]}"; [ -z "${type}" ] && type="${EZB_OPT_NONE}"
            required="${EZB_FUNC_L_ARG_TO_REQUIRED_MAP[${key}]}"; [ -z "${required}" ] && required="${EZB_OPT_NONE}"
            choices="${EZB_FUNC_L_ARG_TO_CHOICES_MAP[${key}]}"; [ -z "${choices}" ] && choices="${EZB_OPT_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZB_FUNC_L_ARG_TO_DEFAULT_MAP["${key}"]}"; [ -z "${default}" ] && default="${EZB_OPT_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZB_FUNC_L_ARG_TO_INFO_MAP["${key}"]}"; [ -z "${info}" ] && info="${EZB_OPT_NONE}"
            [ -z "${short}" ] && short="${EZB_OPT_NONE}" && echo $(ezb_join "${short}" "${long}" "${type}" "${required}" "${default}" "${choices}" "${info}")
        done
    } | column -t -s "${delimiter}"; echo
}

function ezb_function_usage() {
    ezb_function_check_help_keyword "${@}" && ezb_function_print_help -f "${FUNCNAME[1]}" && return || return 1
}

function ezb_set_arg() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        local type_info="[$(ezb_join ', ' ${!EZB_ARG_TYPE_SET[@]})], default = \"${EZB_ARG_TYPE_DEFAULT}\""
        local usage=$(ezb_build_usage -o "init" -d "Register Function Argument")
        usage+=$(ezb_build_usage -o "add" -a "-f|--function" -d "Function Name")
        usage+=$(ezb_build_usage -o "add" -a "-t|--type" -d "Choose from: ${type_info}")
        usage+=$(ezb_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-r|--required" -d "Flag for required argument")
        usage+=$(ezb_build_usage -o "add" -a "-d|--default" -d "Default Value")
        usage+=$(ezb_build_usage -o "add" -a "-c|--choices" -d "Choices for the argument")
        usage+=$(ezb_build_usage -o "add" -a "-i|--info" -d "Argument Description")
        ezb_print_usage "${usage}"
        return
    fi
    declare -A arg_set_of_ezb_set_arg=(
        ["-f"]="1" ["--function"]="1"
        ["-t"]="1" ["--type"]="1"
        ["-s"]="1" ["--short"]="1"
        ["-l"]="1" ["--long"]="1"
        ["-r"]="1" ["--required"]="1"
        ["-d"]="1" ["--default"]="1"
        ["-c"]="1" ["--choices"]="1"
        ["-i"]="1" ["--info"]="1"
    )
    local function=""
    local type="${EZB_ARG_TYPE_DEFAULT}"
    local required="${EZB_BOOL_FALSE}"
    local short=""
    local long=""
    local info=""
    local default=()
    local choices=()
    while [ -n "${1}" ]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; [ -n "${1}" ] && shift ;;
            "-t" | "--type") shift; type=${1}; [ -n "${1}" ] && shift ;;
            "-s" | "--short") shift; short=${1}; [ -n "${1}" ] && shift ;;
            "-l" | "--long") shift; long=${1}; [ -n "${1}" ] && shift ;;
            "-i" | "--info") shift; info=${1}; [ -n "${1}" ] && shift ;;
            "-r" | "--required") shift; required="${EZB_BOOL_TRUE}" ;;
            "-d" | "--default") shift;
                while [ -n "${1}" ]; do [ -n "${arg_set_of_ezb_set_arg["${1}"]}" ] && break; default+=("${1}"); shift; done ;;
            "-c" | "--choices") shift
                while [ -n "${1}" ]; do [ -n "${arg_set_of_ezb_set_arg["${1}"]}" ] && break; choices+=("${1}"); shift; done ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [ -z "${function}" ] && function="${FUNCNAME[1]}"
    [ -z "${short}" ] && [ -z "${long}" ] && ezb_log_error "\"-s|--short\" and \"-l|--long\" are None" && return 1
    if [ -z "${EZB_ARG_TYPE_SET[${type}]}" ]; then
        ezb_log_error "Invalid value \"${type}\" for \"-t|--type\""
        ezb_log_error "Please choose from [$(ezb_join ', ' ${!EZB_ARG_TYPE_SET[@]})]"
        return 1
    fi
    # EZ_BASH_FUNCTION_HELP="--help" is reserved for ez_bash function help
    [[ "${short}" = "${EZB_FUNC_HELP}" ]] && ezb_log_error "Invalid short argument \"${short}\", which is an EZ-BASH reserved keyword" && return 2
    [[ "${long}" = "${EZB_FUNC_HELP}" ]] && ezb_log_error "Invalid long argument \"${long}\", which is an EZ-BASH reserved keyword" && return 2
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    # If the key has already been registered, then skip
    if [ -n "${short}" ] && [ -n "${long}" ]; then
        [ -n "${EZB_FUNC_S_ARG_SET[${function}${delimiter}${short}]}" ] && [ -n "${EZB_FUNC_L_ARG_SET[${function}${delimiter}${long}]}" ] && return
    elif [ -n "${short}" ]; then [ -n "${EZB_FUNC_S_ARG_SET[${function}${delimiter}${short}]}" ] && return
    else [ -n "${EZB_FUNC_L_ARG_SET[${function}${delimiter}${long}]}" ] && return
    fi
    local default_str=""; local i=0
    for ((; i < ${#default[@]}; ++i)); do [ "${i}" -eq 0 ] && default_str="${default[${i}]}" || default_str+="${delimiter}${default[${i}]}"; done
    local choices_str=""; local i=0
    for ((; i < ${#choices[@]}; ++i)); do [ "${i}" -eq 0 ] && choices_str="${choices[${i}]}" || choices_str+="${delimiter}${choices[${i}]}"; done
    # Register Function
    EZB_FUNC_SET["${function}"]="${EZB_BOOL_TRUE}"
    local key=""
    if [ -n "${short}" ]; then
        key="${function}${delimiter}${short}"
        EZB_FUNC_S_ARG_SET["${key}"]="${EZB_BOOL_TRUE}"
        if [ -z "${EZB_FUNC_TO_S_ARG_MAP[${function}]}" ]; then
            EZB_FUNC_TO_S_ARG_MAP["${function}"]="${short}"
        else
            if [ -z "${EZB_FUNC_S_ARG_TO_TYPE_MAP[${key}]}" ]; then
                EZB_FUNC_TO_S_ARG_MAP["${function}"]+="${delimiter}${short}"
            fi
        fi
        EZB_FUNC_S_ARG_TO_L_ARG_MAP["${key}"]="${long}"
        EZB_FUNC_S_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZB_FUNC_S_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZB_FUNC_S_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZB_FUNC_S_ARG_TO_DEFAULT_MAP["${key}"]="${default_str[@]}"
        EZB_FUNC_S_ARG_TO_CHOICES_MAP["${key}"]="${choices_str[@]}"
    else
        key="${function}${delimiter}${long}"
        local short_old="${EZB_FUNC_L_ARG_TO_S_ARG_MAP[${key}]}"
        if [ -n "${short_old}" ]; then
            key="${function}${delimiter}${short_old}"
            # Delete short_old
            unset EZB_FUNC_S_ARG_TO_L_ARG_MAP["${key}"]
            unset EZB_FUNC_S_ARG_TO_TYPE_MAP["${key}"]
            unset EZB_FUNC_S_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZB_FUNC_S_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZB_FUNC_S_ARG_TO_INFO_MAP["${key}"]
            unset EZB_FUNC_S_ARG_TO_CHOICES_MAP["${key}"]
            unset EZB_FUNC_S_ARG_SET["${key}"]
            local new_short_list_string=""; local existing_short=""
            for existing_short in $(sed "s/${delimiter}/ /g" <<< "${EZB_FUNC_TO_S_ARG_MAP[${function}]}"); do
                if [[ "${short_old}" != "${existing_short}" ]]; then
                    if [ -z "${new_short_list_string}" ]; then 
                        new_short_list_string="${existing_short}"
                    else
                        new_short_list_string+="${delimiter}${existing_short}"
                    fi
                fi
            done
            EZB_FUNC_TO_S_ARG_MAP["${function}"]="${new_short_list_string}"
        fi
    fi
    if [ -n "${long}" ]; then
        key="${function}${delimiter}${long}"
        EZB_FUNC_L_ARG_SET["${key}"]="${EZB_BOOL_TRUE}"
        if [ -z "${EZB_FUNC_TO_L_ARG_MAP[${function}]}" ]; then
            EZB_FUNC_TO_L_ARG_MAP["${function}"]="${long}"
        else
            if [ -z "${EZB_FUNC_L_ARG_TO_TYPE_MAP[${key}]}" ]; then
                EZB_FUNC_TO_L_ARG_MAP["${function}"]+="${delimiter}${long}"
            fi
        fi
        EZB_FUNC_L_ARG_TO_S_ARG_MAP["${key}"]="${short}"
        EZB_FUNC_L_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZB_FUNC_L_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZB_FUNC_L_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZB_FUNC_L_ARG_TO_DEFAULT_MAP["${key}"]="${default_str[@]}"
        EZB_FUNC_L_ARG_TO_CHOICES_MAP["${key}"]="${choices_str[@]}"
    else
        key="${function}${delimiter}${short}"
        local long_old="${EZB_FUNC_S_ARG_TO_L_ARG_MAP[${key}]}"
        if [ -n "${long_old}" ]; then
            key="${function}${delimiter}${long_old}"
            # Delete long_old
            unset EZB_FUNC_L_ARG_TO_S_ARG_MAP["${key}"]
            unset EZB_FUNC_L_ARG_TO_TYPE_MAP["${key}"]
            unset EZB_FUNC_L_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZB_FUNC_L_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZB_FUNC_L_ARG_TO_INFO_MAP["${key}"]
            unset EZB_FUNC_L_ARG_TO_CHOICES_MAP["${key}"]
            unset EZB_FUNC_L_ARG_SET["${key}"]
            local new_long_list_string=""; local existing_long=""
            for existing_long in $(sed "s/${delimiter}/ /g" <<< "${EZB_FUNC_TO_L_ARG_MAP[${function}]}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [ -z "${new_short_list_string}" ]; then 
                        new_long_list_string="${existing_long}"
                    else
                        new_long_list_string+="${delimiter}${existing_long}"
                    fi
                fi
            done
            EZB_FUNC_TO_L_ARG_MAP["${function}"]="${new_long_list_string}"
        fi
    fi
}

function ezb_get_arg() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        local usage=$(ezb_build_usage -o "init" -d "Get argument value from argument list")
        usage+=$(ezb_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-a|--arguments" -d "Argument List")
        ezb_print_usage "${usage}"
        echo "[Notes]"
        echo "    Can only be called by another function"
        echo "    The arguments to process must be at the end of this function's argument list"
        echo "[Example]"
        echo "    ${FUNCNAME[0]} -s|--short \${SHORT_ARG} -l|--long \${LONG_ARG} -a|--arguments \"\${@}\""
        echo
        return
    fi
    # Must Run Inside Other Functions
    local function="${FUNCNAME[1]}"
    [ -z "${EZB_FUNC_SET[${function}]}" ] && ezb_log_error "Function \"${function}\" NOT registered" && return 2
    local short=""; local long=""; local arguments=()
    if [ "${1}" = "-s" -o "${1}" = "--short" ]; then short="${2}"
        if [ "${3}" = "-l" -o "${3}" = "--long" ]; then long="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ezb_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ezb_log_error "Invalid argument identifier \"${3}\", expected \"-l|--long\" or \"-a|--arguments\""
            ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    elif [ "${1}" = "-l" -o "${1}" = "--long" ]; then long="${2}"
        if [ "${3}" = "-s" -o "${3}" = "--short" ]; then short="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ezb_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ezb_log_error "Invalid argument identifier \"${5}\", expected \"-s|--short\" or \"-a|--arguments\""
            ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    else
        ezb_log_error "Invalid argument identifier \"${1}\", expected \"-s|--short\" or \"-l|--long\""
        ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    if [ -z "${short}" ] && [ -z "${long}" ]; then
        ezb_log_error "Not found \"-s|--short\" or \"-l|--long\""
        ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    local short_key=""; local long_key=""
    if [ -n "${short}" ]; then
        short_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${short}"
        if [ -z "${EZB_FUNC_S_ARG_SET[${short_key}]}" ]; then
            ezb_log_error "\"${short}\" has NOT been registered as short identifier for function \"${function}\""
            return 2
        fi
    fi
    if [ -n "${long}" ]; then
        long_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${long}"
        if [ -z "${EZB_FUNC_L_ARG_SET[${long_key}]}" ]; then
            ezb_log_error "\"${long}\" has NOT been registered as long identifier for function \"${function}\""
            return 2
        fi
    fi
    if [ -n "${short}" ] && [ -n "${long}" ]; then
        # Check short/long pair matches 
        local match_count=0
        [ "${EZB_FUNC_L_ARG_TO_S_ARG_MAP[${long_key}]}" == "${short}" ] && ((++match_count))
        [ "${EZB_FUNC_S_ARG_TO_L_ARG_MAP[${short_key}]}" == "${long}" ] && ((++match_count))
        if [ "${match_count}" -ne 2 ]; then
            ezb_log_error "The Arg-Short identifier \"${short}\" and the Arg-Long identifier \"${long}\" Not Match"
            ezb_log_error "Expected: Arg-Short \"${short}\" -> Arg-Long \"${EZB_FUNC_S_ARG_TO_L_ARG_MAP[${short_key}]}\""
            ezb_log_error "Expected: Arg-Long \"${long}\" -> Arg-Short \"${EZB_FUNC_L_ARG_TO_S_ARG_MAP[${long_key}]}\""
            return 2
        fi
    fi
    local argument_type=""; local argument_default=""; local argument_choices=""
    if [ -n "${short}" ]; then
        argument_required="${EZB_FUNC_S_ARG_TO_REQUIRED_MAP[${short_key}]}"
        argument_type="${EZB_FUNC_S_ARG_TO_TYPE_MAP[${short_key}]}"
        argument_default="${EZB_FUNC_S_ARG_TO_DEFAULT_MAP[${short_key}]}"
        argument_choices="${EZB_FUNC_S_ARG_TO_CHOICES_MAP[${short_key}]}"
    else
        argument_required="${EZB_FUNC_L_ARG_TO_REQUIRED_MAP[${long_key}]}"
        argument_type="${EZB_FUNC_L_ARG_TO_TYPE_MAP[${long_key}]}"
        argument_default="${EZB_FUNC_L_ARG_TO_DEFAULT_MAP[${long_key}]}"
        argument_choices="${EZB_FUNC_L_ARG_TO_CHOICES_MAP[${long_key}]}"   
    fi
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    if [ -z "${argument_type}" ]; then
        ezb_log_error "Arg-Type for \"${short}\" or \"${long}\" of function \"${function}\" Not Found"; return 3
    fi
    if [ "${argument_type}" = "Flag" ]; then
        local item=""; for item in ${arguments[@]}; do
            if [ "${item}" = "${short}" -o "${item}" = "${long}" ]; then
                echo "${EZB_BOOL_TRUE}"; return
            fi
        done
        echo "${EZB_BOOL_FALSE}"; return
    elif [ "${argument_type}" = "String" ]; then
        local i=0; for ((; i < ${#arguments[@]} - 1; ++i)); do
            local name="${arguments[${i}]}"
            if [ "${arguments[${i}]}" = "${short}" -o "${arguments[${i}]}" = "${long}" ]; then
                ((i++))
                local value="${arguments[${i}]}"
                if [ -n "${argument_choices}" ]; then
                    declare -A choice_set
                    local choice=""; local length="${#argument_choices}"; local last_index=$((length - 1))
                    local k=0; for ((; k < "${length}"; ++k)); do
                        local char="${argument_choices:k:1}"
                        if [ "${char}" = "${delimiter}" ]; then
                            [ -n "${choice}" ] && choice_set["${choice}"]="${EZB_BOOL_TRUE}"
                            choice=""
                        else
                            choice+="${char}"
                        fi
                        [ "${k}" -eq "${last_index}" ] && [ -n "${choice}" ] && choice_set["${choice}"]="${EZB_BOOL_TRUE}"
                    done
                    if [ -z "${choice_set[${value}]}" ]; then
                        local choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ezb_log_error "Invalide value \"${value}\" for argument \"${name}\", please choose from [${choices_string}]"
                        return 4
                    fi
                fi
                # No Choices Restriction
                echo "${value}"; return
            fi
        done
        # Required but not found and no default
        if [ -z "${argument_default}" ] && [ "${argument_required}" = "${EZB_BOOL_TRUE}" ]; then
            [ -n "${short}" ] && ezb_log_error "Argument \"${short}\" is required" && return 5
            [ -n "${long}" ] && ezb_log_error "Argument \"${long}\" is required" && return 5
        fi
        # Not Found, Use Default, Only print the first item in the default list
        local default_value=""; local length="${#argument_default}"; local last_index=$((length - 1))
        local k=0; for ((; k < "${length}"; ++k)); do
            local char="${argument_default:k:1}"
            if [ "${char}" = "${delimiter}" ]; then
                [ -n "${default_value}" ] && echo "${default_value}"
                return
            else
                default_value+="${char}"
            fi
            [ "${k}" -eq "${last_index}" ] && [ -n "${default_value}" ] && echo "${default_value}"
        done
    elif [ "${argument_type}" = "List" ]; then
        local i=0; for ((; i < ${#arguments[@]} - 1; ++i)); do
            local name="${arguments[${i}]}"
            if [ "${arguments[${i}]}" = "${short}" -o "${arguments[${i}]}" = "${long}" ]; then
                local output=""; local count=0
                local j=1; for ((; i + j < ${#arguments[@]}; ++j)); do
                    local index=$((i + j))
                    # List ends with another argument indentifier "-" or end of line
                    [[ "${arguments[${index}]}" =~ "-"[-,a-zA-Z].* ]] && break
                    [ "${count}" -eq 0 ] && output="${arguments[${index}]}" || output+="${delimiter}${arguments[${index}]}"
                    ((++count))
                done
                echo "${output}"; return
            fi
        done
        # Required but not found and no default
        if [ -z "${argument_default}" ] && [ "${argument_required}" = "${EZB_BOOL_TRUE}" ]; then
            [ -n "${short}" ] && ezb_log_error "Argument \"${short}\" is required" && return 5
            [ -n "${long}" ] && ezb_log_error "Argument \"${long}\" is required" && return 5
        fi
        # Not Found, Use Default
        echo "${argument_default}"
    fi
}

